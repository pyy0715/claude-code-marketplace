# Task Planner Plugin

> 영속적 마크다운 기반 계획 시스템 - 컨텍스트 엔지니어링 워크플로우 패턴

## 개요

복잡한 작업을 위해 영속적 마크다운 파일을 "외부 메모리"로 사용하는 워크플로우를 제공합니다. 파일시스템을 무제한 컨텍스트로 활용하여 장기 작업에서도 목표와 진행 상황을 유지합니다.

## 핵심 컨셉

```
컨텍스트 윈도우 = RAM (휘발성, 제한적)
파일시스템 = 디스크 (영속적, 무제한)

→ 중요한 모든 것을 디스크에 기록
```

## 기능

### 3-파일 계획 시스템
- `task_plan.md` - 목표 및 단계 추적
- `findings.md` - 연구 및 발견사항
- `progress.md` - 실시간 세션 로그

### 자동 스킬 호출
복잡한 작업에 Claude가 이 패턴을 자동으로 사용합니다.

### Hook 통합
- **SessionStart**: 파일 자동 초기화
- **PreToolUse**: 계획 파일 재읽기 트리거
- **PostToolUse**: 업데이트 알림
- **Stop**: 완료 체크

### 템플릿
모든 계획 파일을 위한 사전 제작 템플릿

### 자동화 스크립트
- `init-session.sh` - 계획 파일 초기화
- `check-complete.sh` - 단계 완료 확인

## 설치

### Claude Code에서

```bash
# 플러그인 디렉토리로 이동
cd ~/.claude/plugins

# 이 플러그인 복사
cp -r /path/to/plan .

# 또는 심볼릭 링크 (개발용)
ln -s /path/to/plan .
```

### 스크립트 실행 권한 설정

```bash
chmod +x ~/.claude/plugins/plan/skills/planning-with-files/scripts/*.sh
```

## 사용 방법

이 플러그인은 **자동 + 수동** 두 가지 방식으로 작동합니다.

### 자동 사용 (권장)

**Skill이 자동으로 활성화:**

Claude가 복잡한 작업을 감지하면 `planning-with-files` skill을 자동으로 사용합니다:

```
사용자: "대규모 REST API 시스템을 설계하고 구현해줘"
    ↓
Claude: [복잡한 다단계 작업 감지]
    ↓
planning-with-files skill 자동 활성화
    ↓
init-session.sh 실행 → docs/<plan>/ 생성
    ↓
작업 진행하면서 PreToolUse hook이 task_plan.md 자동 주입
```

**자동 활성화 조건:**
- 5회 이상 도구 호출이 예상되는 작업
- 명확한 단계가 필요한 작업
- 연구와 구현이 혼합된 작업

### 수동 사용

**Commands로 명시적 호출:**

특정 워크플로우가 필요할 때 명령어 사용:

```bash
# 1. 전체 자동화 워크플로우
/plan "REST API 인증 시스템 구현"
→ plan-coordinator agent 활성화
→ 계획 수립 → 검토 → 개선 사이클

# 2. 기존 계획 검토
/plan:review
→ plan-reviewer agent 활성화
→ task_plan.md 비판적 검토

# 3. 현재 상태 확인
/plan:status
→ 진행 상황 요약 출력

# 4. 리포트 내보내기
/plan:export
→ 통합 리포트 생성
```

### Subagent 트리거 방식

**자동 트리거:**

Claude가 commands의 description을 읽고 적절한 agent를 자동 선택:

```markdown
# commands/plan.md
---
description: 계획 수립 자동화 워크플로우 - 계획 생성부터 검토까지...
---

**이제 plan-coordinator agent를 활성화하여 자동 워크플로우를 시작합니다...**
```

Claude가 이 설명을 읽으면:
1. `plan-coordinator` agent의 페르소나 채택
2. Agent의 시스템 프롬프트 로드
3. Agent의 tools로 작업 수행
4. 필요 시 다른 agent 호출 (자연어 판단)

**명시적 요청:**

사용자가 직접 agent 지정 가능:

```
"plan-coordinator를 사용해서 이 프로젝트 계획을 세워줘"
"plan-reviewer agent로 내 계획을 검토해줘"
```

### Agent 간 조율

**plan-coordinator의 자연어 기반 조율:**

```markdown
# plan-coordinator.md 본문

### 2. Agent 조율
다른 전문 agent들을 적절한 시점에 호출:
- **plan-reviewer**: 비판적 검토가 필요할 때
- **decision-maker**: 중요한 기술 결정 시점
```

Claude가 이를 읽고:
- "검토가 필요하다" 판단 → plan-reviewer 페르소나로 전환
- "의사결정이 필요하다" 판단 → decision-maker 페르소나로 전환

**핵심:** API 호출이 아닌 **자연어 설명 기반 조율**

## 빠른 시작

### 1. 계획 파일 초기화

프로젝트 디렉토리에서:

```bash
# 작업 설명으로 자동 생성 (권장)
~/.claude/plugins/plan/skills/planning-with-files/scripts/init-session.sh "REST API 인증 시스템"
# → docs/rest-api-인증-시스템/ 생성

# 또는 직접 plan 이름 지정
~/.claude/plugins/plan/skills/planning-with-files/scripts/init-session.sh api-auth
# → docs/api-auth/ 생성

# 또는 수동 (직접 생성)
mkdir -p docs/my-plan
# 템플릿은 init-session.sh에 내장되어 있음
```

**결과:**
```
docs/
└── rest-api-인증-시스템/    # 또는 api-auth/
    ├── task_plan.md
    ├── findings.md
    └── progress.md
```

### 2. task_plan.md 작성

목표와 단계로 편집:

```markdown
# 작업 계획: REST API 구축

## 목표
사용자 인증이 있는 REST API 생성

## 단계
- [ ] 단계 1: 요구사항 및 설계
- [ ] 단계 2: 데이터베이스 설정
- [ ] 단계 3: 엔드포인트 구현
- [ ] 단계 4: 테스트
- [ ] 단계 5: 문서화
```

### 3. 작업 시작

Claude는 자동으로:
- 연구 후 findings.md 업데이트
- 오류 및 진행상황 기록
- 결정 전 task_plan.md 재읽기
- 중단 전 완료 확인

## 3개 파일

### task_plan.md - 북극성
- **목적**: 목표, 단계, 진행상황 추적
- **업데이트**: 단계 전환 시
- **이유**: 많은 도구 호출 후 목표를 주의로 되돌림

### findings.md - 연구 로그
- **목적**: 발견사항 및 기술 결정 저장
- **업데이트**: 2회 연속 조사 작업 후 (2-Action Rule)
- **이유**: 재조사 방지 및 학습 문서화

### progress.md - 세션 로그
- **목적**: 타임스탬프가 있는 실시간 활동 로그
- **업데이트**: 작업 발생 시 지속적으로
- **이유**: 계획 대비 실제 작업 추적

## 핵심 원칙

### 1. 계획을 먼저 수립
task_plan.md 없이 시작하지 마세요.

### 2. 2-Action Rule
2회 연속 조사 작업 후 findings.md 업데이트.

### 3. 결정 전 재읽기
주요 결정 전에 task_plan.md 읽어서 목표 새로고침.

### 4. 모든 오류 기록
타임스탬프, 원인, 해결방법과 함께 모든 오류 기록.

### 5. 점진적 업데이트
작은 변경은 file.edit 사용. 전체 재작성 금지.

## 자동 동작

### Hooks (Skill 통합)

`planning-with-files` skill이 자동으로:

- **SessionStart**: Skill 활성화 알림
- **PreToolUse**: 
  - Write/Edit/Bash 전에 `docs/*/task_plan.md` 재읽기 (주의 조작)
  - WebFetch/Search/Read 후 2-Action Rule 체크
- **PostToolUse**: 파일 업데이트 후 상태 업데이트 알림
- **Stop**: 중단 허용 전 모든 계획의 미완료 단계 확인

> **참고**: Hooks는 skill에 통합되어 있어 더 모듈화되고 독립적입니다.

### 스킬 호출

Claude는 다음 경우 이 패턴을 자동으로 사용:
- 새로운 코딩 작업 시작
- 복잡한 다단계 프로젝트 작업
- 연구가 필요한 작업
- 30분 이상 지속되는 세션
- 오류 발생 후

## 명령어

### /plan "작업 설명"
전체 자동화 워크플로우 - 계획 생성에서 검토까지.

```bash
/plan "REST API 인증 시스템 구현"
```

### /plan:review [파일명]
계획 파일 비판적 검토.

```bash
/plan:review              # 전체 검토
/plan:review task_plan.md # 특정 파일만
```

### /plan:status
현재 진행 상황 및 상태 확인.

```bash
/plan:status
```

### /plan:export [형식]
통합 리포트로 계획 파일 내보내기.

```bash
/plan:export          # Markdown
/plan:export pdf      # PDF (예정)
```

### /plan:help
전체 도움말 및 사용 가이드.

```bash
/plan:help
```

## 플러그인 아키텍처

이 플러그인은 **Context Engineering** 기반의 3계층 구조입니다:

### 계층 구조

```
Commands (진입점)
    ↓ 설명 기반 활성화
Agents (전문 페르소나)
    ↓ 컨텍스트 공유
Skills (도구 + 자동화)
```

### 작동 원리

**1. Commands**: 사용자 인터페이스
- `/plan` 같은 슬래시 커맨드
- 어떤 agent를 활성화할지 **자연어로 설명**
- Claude가 이 설명을 읽고 해당 agent 페르소나 채택

**2. Agents**: 전문화된 사고 방식
- `plan-coordinator`: 워크플로우 조율 전문가
- `plan-reviewer`: 비판적 검토 전문가
- `decision-maker`: 의사결정 지원 전문가
- Claude가 agent의 가이드라인을 읽고 그 **역할로 행동**

**3. Skills**: 실행 가능한 도구와 자동화
- `planning-with-files`: 계획 파일 관리 스킬
- Hooks로 자동 동작 (PreToolUse, Stop 등)
- 스크립트와 템플릿 제공
- **전역적으로 사용 가능** (모든 agent가 접근)

### 핵심 특징

**상속이 아닌 공존**:
- Agents가 Skills를 "상속"하지 않음
- 같은 컨텍스트 공간에 **공존**
- Agent 실행 시 Claude는 자연스럽게 모든 컴포넌트에 접근

**Description-based 조율**:
- 전통적 API 호출 대신 **자연어 설명**
- "plan-reviewer를 호출합니다" → Claude가 읽고 reviewer 페르소나로 전환
- **Prompt engineering이 아키텍처**

## 파일 구조

```
plugins/plan/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 메타데이터
├── commands/                     # 슬래시 명령어 (진입점)
│   ├── plan.md                  # /plan - coordinator 활성화
│   ├── plan-review.md           # /plan:review - reviewer 활성화
│   ├── plan-status.md           # /plan:status - 상태 확인
│   ├── plan-export.md           # /plan:export - 리포트 생성
│   └── plan-help.md             # /plan:help - 도움말
├── agents/                       # 전문 에이전트 (페르소나)
│   ├── plan-coordinator.md      # 워크플로우 조율
│   ├── plan-reviewer.md         # 비판적 검토
│   └── decision-maker.md        # 의사결정 지원
├── skills/                       # 도구 + 자동화 (전역)
│   └── planning-with-files/
│       ├── SKILL.md            # 스킬 정의 (hooks 포함)
│       ├── reference.md        # 컨텍스트 엔지니어링 원칙
│       ├── examples.md         # 실전 예시
│       ├── templates/          # 계획 파일 템플릿
│       └── scripts/            # 자동화 스크립트
│           ├── init-session.sh         # 계획 파일 초기화
│           └── check-complete.sh       # 완료 검증
└── README.md                    # 이 파일
```

## 예시

자세한 워크스루는 `skills/planning-with-files/examples.md` 참조:
- 커맨드라인 todo 앱 개발
- 인증 버그 디버깅
- 주의 조작 패턴

## 컨텍스트 엔지니어링 원칙

이 플러그인은 6가지 핵심 원칙을 구현:

### 1. 파일을 무제한 메모리로
파일시스템 = 무제한 컨텍스트

### 2. 주의 조작
계획 재읽기로 목표를 되돌림

### 3. 오류 투명성
모든 오류 기록, 숨기지 않음

### 4. 점진적 업데이트
파일 편집, 재작성하지 않음

### 5. 구조화된 지식
파일별 관심사 분리

### 6. 지속적 컨텍스트
세션을 넘어 생존

## 팁

### 큰 작업을 3-5단계로 분해
task_plan.md에서

### 연구 후 즉시 findings.md 업데이트
기다리지 말 것

### 실시간 로깅에 progress.md 사용
일기처럼

### 10-15회 도구 호출마다 task_plan.md 재읽기
목표 새로고침

### 자연스러운 구분점에서 체크포인트
점심, 하루 종료

## 문제 해결

### 계획 파일이 생성되지 않음
- init-session.sh 수동 실행
- 프로젝트 디렉토리에 있는지 확인
- 템플릿 설치 확인

### Hooks가 작동하지 않음
- 스크립트를 실행 가능하게: `chmod +x scripts/*.sh`
- CLAUDE_PLUGIN_ROOT가 올바르게 설정되었는지 확인
- Claude Code 재시작

### 2-Action Rule이 트리거되지 않음
- PreToolUse hook 활성화 확인
- check-2-action-rule.sh 실행 가능 확인

## 모범사례

### 해야 할 것

✅ 항상 계획 먼저
✅ 2회 연속 조사 후 findings 업데이트
✅ 모든 오류를 타임스탬프와 함께 기록
✅ 주요 결정 전 계획 재읽기
✅ 작은 변경은 점진적 업데이트

### 하지 말아야 할 것

❌ 계획 없이 시작
❌ 연구 내용 미기록
❌ 오류 숨기기
❌ 파일 방치
❌ 전체 파일 재작성
❌ 실패한 행동 반복

## 크레딧

원본 플러그인 영감: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files)

## 라이선스

MIT

---

**핵심**: 파일시스템을 외부 메모리로 사용하세요. 주의를 조작하세요. 모든 오류를 기록하세요.
