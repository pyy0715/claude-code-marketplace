---
name: planning-with-files
version: "1.0.0"
description: 파일 기반 계획 시스템 구현. task_plan.md, findings.md, progress.md 생성. 복잡한 다단계 작업, 연구 프로젝트, 5회 이상 도구 호출이 필요한 작업에 사용.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
hooks:
  SessionStart:
    - hooks:
        - type: command
          command: "echo '[planning-with-files] 준비 완료. 복잡한 작업에 자동 활성화.'"
  PreToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: "find docs/*/task_plan.md 2>/dev/null | head -1 | xargs cat 2>/dev/null | head -30 || true"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "echo '[planning-with-files] 파일 업데이트됨. 단계 완료 시 docs/<plan>/task_plan.md 상태 업데이트.'"
  Stop:
    - hooks:
        - type: validation
          script: "${CLAUDE_PLUGIN_ROOT}/scripts/check-complete.sh"
---

# Planning with Files

지속적인 마크다운 파일을 "디스크의 작업 메모리"로 사용하세요.

## Language Rule

**생성하는 모든 파일(task_plan.md, findings.md, progress.md)은 반드시 한글로 작성합니다.**

스타일 가이드:
- **헤더(##, ###)**: 영어로 작성 (예: `## Phase 1: Foundation`, `## Current Status`)
- **본문 내용**: 한글로 작성 (작업 설명, 완료 기준, 노트 등)
- **주석 (<!-- -->)**: 한글로 작성
- **예외**: 코드, 명령어, 파일명은 원래대로 유지

예시:
```markdown
## Phase 1: Foundation
- [ ] Task 1.1: 데이터베이스 스키마 설계 및 마이그레이션 파일 작성
```

## File Storage Location

이 스킬 사용 시:

- **템플릿**은 스킬 디렉토리 `${CLAUDE_PLUGIN_ROOT}/templates/`에 저장됨
- **계획 파일들**은 **`docs/<plan-name>/`** 디렉토리에 생성

| 위치 | 저장 내용 |
|----------|-----------------|
| 스킬 디렉토리 (`${CLAUDE_PLUGIN_ROOT}/`) | 템플릿, 스크립트, 참조 문서 |
| `docs/<plan-name>/` | `task_plan.md`, `findings.md`, `progress.md` |

**예시 구조:**
```
your-project/
├── docs/
│   ├── api-auth/           # REST API 인증 계획
│   │   ├── task_plan.md
│   │   ├── findings.md
│   │   └── progress.md
│   └── frontend-refactor/  # 프론트엔드 리팩토링 계획
│       ├── task_plan.md
│       ├── findings.md
│       └── progress.md
└── src/
    └── ...
```

**장점:**
- 프로젝트 루트가 깔끔하게 유지됨
- 여러 계획을 동시에 관리 가능
- docs/ 폴더에 문서 집중
- 계획별로 격리된 컨텍스트

**디렉토리 자동 생성:**
디렉토리가 없으면 자동으로 생성됩니다.

## Quick Start

복잡한 작업 시작 전 반드시:

1. **계획 디렉토리 생성** - `docs/<plan-name>/` (작업 설명에서 자동 생성)
2. **3개 파일 자동 생성** - `task_plan.md`, `findings.md`, `progress.md`
3. **결정 전 계획 재읽기** - 결정을 내리기 전에 계획을 재검토하여 목표를 다시 상기한다.
4. **각 단계 후 업데이트** - 완료 표시, 오류 기록

> **참고:** plan-name은 작업 설명에서 자동으로 kebab-case로 변환됩니다.
> 예: "REST API 인증" → `rest-api-인증`
> 예: "프론트엔드 리팩토링" → `프론트엔드-리팩토링`

## Core Pattern

```
컨텍스트 윈도우 = RAM (휘발성, 제한적)
파일시스템 = 디스크 (영속적, 무제한)

→ 중요한 모든 것을 디스크에 기록
```

## File Purpose

| 파일 | 목적 | 업데이트 시점 |
|------|---------|----------------|
| `task_plan.md` | 단계, 진행상황, 결정사항 | 각 단계 후 |
| `findings.md` | 연구, 발견사항 | 발견 즉시 |
| `progress.md` | 세션 로그, 테스트 결과 | 세션 전체 |

## Core Rules

### 1. 계획을 먼저 수립
복잡한 작업을 `task_plan.md` 없이 시작하지 마세요. 절대 금지.

### 2. 2-Action Rule
> "2회 연속 조회/브라우징/검색 작업 후 즉시 핵심 발견사항을 텍스트 파일에 저장하세요."

시각/멀티모달 정보 손실 방지.

### 3. 결정 전 재읽기
주요 결정 전 계획 파일을 읽으세요. 목표를 주의 윈도우에 유지합니다.

### 4. 행동 후 업데이트
단계 완료 후:
- 단계 상태 표시: `진행중` → `완료`
- 발생한 오류 기록
- 생성/수정한 파일 메모

### 5. Record All Errors
모든 오류를 계획 파일에 기록. 지식 축적 및 반복 방지.

```markdown
## 발생한 오류
| 오류 | 시도 | 해결 방법 |
|-------|---------|------------|
| FileNotFoundError | 1 | 기본 설정 파일 생성 |
| API timeout | 2 | 재시도 로직 추가 |
```

### 6. No Repeated Failures
```
if action_failed:
    next_action != same_action
```
시도한 내용 추적. 접근 방식 변경.

## 3-Strike Error Protocol

```
시도 1: 진단 및 수정
  → 오류 신중히 읽기
  → 근본 원인 파악
  → 타겟 수정 적용

시도 2: 대안 접근
  → 같은 오류? 다른 방법 시도
  → 다른 도구? 다른 라이브러리?
  → 절대 똑같은 실패 행동 반복 금지

시도 3: 광범위한 재고
  → 가정에 의문 제기
  → 해결책 검색
  → 계획 업데이트 고려

3회 실패 후: 사용자에게 에스컬레이션
  → 시도한 내용 설명
  → 구체적 오류 공유
  → 안내 요청
```

## Read vs Write Decision Matrix

| 상황 | 행동 | 이유 |
|-----------|--------|--------|
| 방금 파일 작성 | 읽지 말 것 | 내용이 여전히 컨텍스트에 있음 |
| 이미지/PDF 조회 | 즉시 findings 작성 | 멀티모달 → 텍스트로 변환 필요 |
| 브라우저 데이터 반환 | 파일에 작성 | 스크린샷은 지속되지 않음 |
| 새 단계 시작 | 계획/findings 읽기 | 컨텍스트 오래되면 재정렬 |
| 오류 발생 | 관련 파일 읽기 | 수정을 위한 현재 상태 필요 |
| 중단 후 재개 | 모든 계획 파일 읽기 | 상태 복구 |

## 5-Question Reboot Test

이 질문에 답할 수 있다면 컨텍스트 관리가 탄탄합니다:

| 질문 | 답변 출처 |
|----------|---------------|
| 어디에 있나? | task_plan.md의 현재 단계 |
| 어디로 가는가? | 남은 단계들 |
| 목표는 무엇인가? | 계획의 목표 진술 |
| 무엇을 배웠나? | findings.md |
| 무엇을 했나? | progress.md |

## When to Use

**사용:**
- 다단계 작업 (3단계 이상)
- 연구 작업
- 프로젝트 구축/생성
- 많은 도구 호출이 필요한 작업
- 조직화가 필요한 작업

**생략:**
- 간단한 질문
- 단일 파일 편집
- 빠른 조회

## Templates

계획 파일 템플릿은 `init-session.sh` 스크립트에 내장되어 있습니다.
`init-session.sh <작업명>`을 실행하면 자동으로 생성됩니다.

## Scripts

자동화를 위한 헬퍼 스크립트:

- `scripts/init-session.sh` — 모든 계획 파일 초기화 (`docs/<plan>/` 생성)
- `scripts/check-complete.sh` — 모든 계획의 단계 완료 확인

## Advanced Topics

- **컨텍스트 엔지니어링 원칙:** [reference.md](reference.md) 참조
- **실전 예시:** [examples.md](examples.md) 참조

## Anti-patterns

| 하지 말 것 | 대신 할 것 |
|-------|------------|
| TodoWrite로 영속성 관리 | task_plan.md 파일 생성 |
| 목표를 한 번만 언급하고 잊기 | 결정 전 계획 재읽기 |
| 오류 숨기고 조용히 재시도 | 계획 파일에 오류 기록 |
| 모든 것을 컨텍스트에 채우기 | 큰 내용은 파일에 저장 |
| 즉시 실행 시작 | 계획 파일 먼저 생성 |
| 실패한 행동 반복 | 시도 추적, 접근 방식 변경 |
| 스킬 디렉토리에 파일 생성 | docs/<plan-name>/에 파일 생성 |

## Key Principles Summary

### Files = Unlimited Memory
컨텍스트 윈도우는 제한적. 파일시스템은 무제한.

### Attention Manipulation
계획 파일을 재읽어 목표를 주의 윈도우로 되돌림.

### Error Transparency
모든 오류 기록. 학습 및 반복 방지.

### Incremental Updates
작은 변경은 Edit 도구. 전체 재작성 금지.

### Structured Knowledge
관심사 분리: 3개 파일이 각각 명확한 목적.

### Persistent Context
파일은 세션을 넘어 지속됨.

## Key Insights

> "마크다운은 디스크의 작업 메모리입니다."

> "컨텍스트를 엔지니어링하는 것이 핵심입니다."

---

**핵심**: 파일시스템을 외부 메모리로 사용하세요. 주의를 조작하세요. 모든 오류를 기록하세요.
