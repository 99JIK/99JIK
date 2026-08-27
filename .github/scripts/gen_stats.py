"""프로필 활동 통계 SVG 생성기.

github-readme-stats.vercel.app과 streak-stats.demolab.com을 대체한다. 둘 다 공용
인스턴스가 레이트리밋으로 상시 죽어 README에 깨진 이미지가 떴다. 여기서 직접
GraphQL을 때려 SVG를 만들어 커밋하면 외부 가용성에 걸리지 않는다.

라이트/다크 두 벌을 낸다. GitHub README는 <picture>의 prefers-color-scheme만
신뢰할 수 있다. SVG 안에 미디어쿼리를 넣는 방식은 <img>로 렌더링될 때 GitHub
테마가 아니라 뷰어 OS 설정을 따라가서 어긋난다.
"""

import json
import os
import sys
import urllib.request
from datetime import datetime

API = "https://api.github.com/graphql"
LOGIN = os.environ.get("GH_LOGIN", "99JIK")
TOKEN = os.environ["GH_TOKEN"]
OUT = os.environ.get("OUT_DIR", "assets")

QUERY = """
query($login: String!) {
  user(login: $login) {
    contributionsCollection {
      totalCommitContributions
      restrictedContributionsCount
      totalRepositoryContributions
    }
    # privacy: PUBLIC이 없으면 비공개 저장소까지 세어 "public repos" 숫자가 틀린다.
    # 언어 집계도 비공개 저장소 내용이 섞여 공개 프로필과 어긋난다.
    repositories(first: 100, ownerAffiliations: OWNER, isFork: false, privacy: PUBLIC) {
      totalCount
      nodes {
        stargazerCount
        languages(first: 10, orderBy: {field: SIZE, direction: DESC}) {
          edges { size node { name color } }
        }
      }
    }
  }
}
"""

THEMES = {
    "light": dict(text="#1f2328", muted="#656d76", accent="#0969da", border="#d1d9e0", track="#eaeef2"),
    "dark":  dict(text="#e6edf3", muted="#8b949e", accent="#58a6ff", border="#3d444d", track="#21262d"),
}

# 언어 색이 비어 있는 경우의 폴백. GitHub linguist에 색이 없는 언어가 가끔 있다.
FALLBACK_COLOR = "#8b949e"

# .ipynb는 실행 결과(이미지 base64 등)가 파일에 그대로 박혀 바이트 크기가 실제 작성한
# 코드량과 무관하게 부푼다. 넣어 두면 노트북 한 저장소가 65%를 먹어 나머지가 안 보인다.
# 되살리려면 이 집합을 비우면 된다.
EXCLUDE_LANGUAGES = {"Jupyter Notebook"}


def fetch():
    req = urllib.request.Request(
        API,
        data=json.dumps({"query": QUERY, "variables": {"login": LOGIN}}).encode(),
        headers={
            "Authorization": "bearer " + TOKEN,
            "Content-Type": "application/json",
            "User-Agent": LOGIN + "-profile-stats",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        payload = json.load(r)
    if "errors" in payload:
        sys.exit("GraphQL error: " + json.dumps(payload["errors"]))
    return payload["data"]["user"]


def languages(nodes, top=6):
    sizes, colors = {}, {}
    for repo in nodes:
        for e in repo["languages"]["edges"]:
            name = e["node"]["name"]
            if name in EXCLUDE_LANGUAGES:
                continue
            sizes[name] = sizes.get(name, 0) + e["size"]
            colors[name] = e["node"]["color"] or FALLBACK_COLOR
    total = sum(sizes.values())
    if not total:
        return []
    ranked = sorted(sizes.items(), key=lambda kv: -kv[1])[:top]
    return [(n, s * 100.0 / total, colors[n]) for n, s in ranked]


def esc(s):
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def render(theme, stats, langs, stamp):
    c = THEMES[theme]
    W, PAD = 840, 24
    inner = W - PAD * 2
    font = "-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif"
    p = []
    add = p.append

    add('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="228" '
        'viewBox="0 0 %d 228" role="img" aria-label="GitHub activity summary">' % (W, W))
    add('<style>text{font-family:%s}</style>' % font)
    add('<rect x="0.5" y="0.5" width="%d" height="227" rx="12" fill="none" stroke="%s"/>'
        % (W - 1, c["border"]))

    add('<text x="%d" y="38" font-size="14" font-weight="600" fill="%s">Activity</text>'
        % (PAD, c["text"]))
    add('<text x="%d" y="38" text-anchor="end" font-size="11" fill="%s">%s</text>'
        % (W - PAD, c["muted"], esc(stamp)))

    # 고정폭 좌측 정렬. 항목 수가 적어 균등분할하면 사이가 허전하게 뜬다.
    col = 180.0
    for i, (value, label) in enumerate(stats):
        x = PAD + col * i
        add('<text x="%.1f" y="96" font-size="26" font-weight="600" fill="%s">%s</text>'
            % (x, c["accent"] if i == 0 else c["text"], esc(value)))
        add('<text x="%.1f" y="116" font-size="11" fill="%s">%s</text>'
            % (x, c["muted"], esc(label)))

    add('<line x1="%d" y1="142" x2="%d" y2="142" stroke="%s"/>' % (PAD, W - PAD, c["border"]))

    # 언어 막대. 조각이 하나뿐이어도 라운드가 유지되도록 트랙 위에 클립해서 그린다.
    add('<text x="%d" y="172" font-size="11" fill="%s">Languages</text>' % (PAD, c["muted"]))
    bar_y = 182
    add('<clipPath id="bar"><rect x="%d" y="%d" width="%d" height="8" rx="4"/></clipPath>'
        % (PAD, bar_y, inner))
    add('<rect x="%d" y="%d" width="%d" height="8" rx="4" fill="%s"/>'
        % (PAD, bar_y, inner, c["track"]))
    add('<g clip-path="url(#bar)">')
    x = float(PAD)
    for _, pct, color in langs:
        w = inner * pct / 100.0
        add('<rect x="%.2f" y="%d" width="%.2f" height="8" fill="%s"/>' % (x, bar_y, w, color))
        x += w
    add('</g>')

    # 범례. 11px에서 글자 폭이 대략 6.1px이라 그걸로 다음 항목 위치를 잡는다.
    x = float(PAD)
    for name, pct, color in langs:
        label = "%s %.1f%%" % (name, pct)
        add('<circle cx="%.1f" cy="211" r="4" fill="%s"/>' % (x + 4, color))
        add('<text x="%.1f" y="215" font-size="11" fill="%s">%s</text>'
            % (x + 14, c["muted"], esc(label)))
        x += 14 + len(label) * 6.1 + 18
    add('</svg>')
    return "\n".join(p)


def main():
    u = fetch()
    cc = u["contributionsCollection"]
    repos = u["repositories"]["nodes"]

    # 값이 0인 지표는 싣지 않는다. 스타/연속일/PR 수는 지금 전부 0이거나 한 자리라
    # 표시하면 없느니만 못하다. 실제로 의미 있는 셋만 남긴다.
    stats = [
        ("{:,}".format(u["repositories"]["totalCount"]), "public repos"),
        ("{:,}".format(cc["totalCommitContributions"]), "commits (1y)"),
        ("{:,}".format(cc["totalRepositoryContributions"]), "repos created (1y)"),
    ]
    langs = languages(repos)
    stamp = datetime.utcnow().strftime("%Y-%m-%d")

    os.makedirs(OUT, exist_ok=True)
    for theme in THEMES:
        path = os.path.join(OUT, "stats-%s.svg" % theme)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(render(theme, stats, langs, stamp))
        print("wrote", path)


if __name__ == "__main__":
    main()
