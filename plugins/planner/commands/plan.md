---
description: Systematic planning workflow - creates optimized plans through drafting, review, and refinement
argument-hint: "[task description]"
allowed-tools: ["Read", "Write", "Grep", "Glob", "Bash", "TodoWrite", "AskUserQuestion", "Skill", "Task"]
---

# Plan Workflow

$ARGUMENTS에 대한 체계적인 계획을 수립하고 검토합니다.

## Core Principles

- **Orchestrate subagents sequentially**: 메인 agent(당신)가 plan-workflow → plan-reviewer → decision-maker 순서로 subagent들을 호출하고 결과를 통합합니다. Subagent는 다른 subagent를 호출할 수 없습니다.
- **Track convergence criteria**: 검토 점수 8.0 이상 또는 최대 3회 반복까지 개선 사이클을 관리합니다. 점수와 반복 횟수를 명확히 추적하세요.
- **Maintain context between phases**: 각 subagent의 결과를 다음 subagent에 전달합니다. 검토 결과의 개선안을 plan-workflow 재호출 시, 명시적으로 제공하세요.
- **Use TodoWrite**: 각 Phase 시작과 완료 시점에 todo 상태를 업데이트하여 진행 상황을 추적합니다.
- **Provide clear summaries**: 각 Phase 완료 후 결과를 간결하게 요약하고, 최종 확정 시 전체 계획 개요를 제공합니다.

**작업 내용:** $ARGUMENTS

---

## Phase 1: 계획 초안 작성

**Goal**: 체계적인 계획 초안을 작성합니다

**Actions**:
1. **plan-workflow subagent 호출**:
   - 작업 내용 전달: $ARGUMENTS
   - Subagent가 다음을 수행:
     - `docs/<plan-name>/` 생성
     - task_plan.md에 Phase별 계획 작성
     - findings.md에 기술 결정사항 기록
   - 결과 받기: 계획 초안 완성 확인

2. **초안 확인**:
   - task_plan.md 파일 읽기
   - 계획 구조 확인 (Phase, Task 구성)
   - 명확한 목표와 단계가 있는지 확인

**Output**: docs/<plan-name>/task_plan.md에 계획 초안 완성

---

## Phase 2: 비판적 검토

**Goal**: 계획의 정합성과 현실성을 검토합니다

**Actions**:
1. **plan-reviewer subagent 호출**:
   - 계획 파일 위치 전달: docs/<plan-name>/
   - Subagent가 다음을 검토:
     - 정합성: Phase 간 논리적 연결
     - 현실성: 일정과 리소스의 적절성
     - 완성도: 누락된 요소
   - 결과 받기:
     - 검토 점수 (0-10)
     - 발견된 문제점
     - 구체적 개선안

2. **결과 분석**:
   - 점수가 8.0 이상이면 → Phase 4로 이동
   - 점수가 8.0 미만이면 → Phase 3로 계속

**Output**: 검토 점수와 개선안

---

## Phase 3: 의사결정 지원 (필요 시)

**Goal**: 복잡한 기술 선택에 대한 의사결정 지원

**Condition**: 검토 결과에 기술 선택이 필요한 경우만 실행

**Actions**:
1. **decision-maker subagent 호출**:
   - 의사결정 항목 전달 (검토에서 발견된 것)
   - Subagent가 다음을 수행:
     - 옵션 비교 분석
     - 트레이드오프 평가
     - 권장안 도출
   - 결과 받기: 의사결정 권장사항

2. **findings.md 업데이트**:
   - 의사결정 결과를 findings.md에 기록
   - 선택한 옵션과 이유 명시

**Output**: 의사결정 완료 및 문서화

---

## Phase 4: 개선 및 재검토

**Goal**: 검토 결과를 반영하여 계획을 개선합니다

**Actions**:
1. **개선 필요 판단**:
   - 검토 점수 < 8.0 이면 개선 필요
   - 반복 횟수 확인 (최대 3회)

2. **plan-workflow subagent 재호출** (개선 필요 시):
   - 검토 결과와 개선안 전달
   - Subagent가 task_plan.md 수정
   - 결과 받기: 개선된 계획

3. **plan-reviewer subagent 재호출**:
   - 개선된 계획 재검토
   - 점수 개선 확인

4. **수렴 조건 체크**:
   - 점수 >= 8.0: 확정
   - 반복 횟수 >= 3: 현재 상태로 확정
   - 그 외: Phase 2로 돌아가 재검토

**Output**: 최적화된 계획 또는 반복 계속

---

## Phase 5: 최종 확정

**Goal**: 계획을 확정하고 사용자에게 요약 제공

**Actions**:
1. **최종 계획 읽기**:
   - task_plan.md 전체 읽기
   - findings.md 읽기
   - 주요 내용 추출

2. **요약 생성**:
   ```markdown
   ✅ 계획 수립 완료!

   📋 계획 위치
   docs/<plan-name>/
   - task_plan.md: 전체 계획 (Phase별 단계)
   - findings.md: 기술 결정사항
   - progress.md: 진행 로그 (작업 시 사용)

   📊 계획 요약
   - 총 Phase: X개
   - 총 Task: Y개
   - 예상 기간: Z일
   - 검토 점수: 8.5/10

   🔍 주요 내용
   - [Phase 1 요약]
   - [Phase 2 요약]
   - [핵심 기술 선택]

   🎯 다음 단계
   작업을 시작하세요. planning-with-files skill의 PreToolUse hook이
   자동으로 task_plan.md를 주입하여 계획을 유지합니다.

   작업 중에는:
   - findings.md에 발견사항 기록 (2-Action Rule)
   - progress.md에 진행 상황 기록
   - task_plan.md 체크박스 업데이트
   ```

3. **사용자에게 제공**

**Output**: 최종 계획 요약 및 다음 단계 안내

---

## Important Notes

### Subagent Orchestration

**당신(메인 agent)의 역할:**
- ✅ 각 subagent에 작업 위임
- ✅ 결과 받아서 다음 단계 결정
- ✅ 반복 횟수 추적
- ✅ 수렴 조건 판단
- ✅ 전체 컨텍스트 유지

**Subagent의 역할:**
- 독립된 컨텍스트에서 전문 작업 수행
- planning-with-files skill 로드하여 가이드라인 참조
- 결과를 당신에게 반환
- 다른 subagent 호출 불가

### Convergence Criteria

다음 조건 중 하나 만족 시 확정:
1. 검토 점수 >= 8.0/10
2. 반복 횟수 >= 3회
3. 개선 여지 < 10% (reviewer 판단)

### Quality Standards

모든 계획은 다음 기준을 충족해야 합니다:
- ✅ 명확한 목표 정의
- ✅ Phase별 논리적 단계 분해
- ✅ 현실적인 일정 수립
- ✅ 기술 결정사항 문서화
- ✅ 완료 기준 명시

---

## Workflow Summary

```
Phase 1: 초안 작성
  ↓ (plan-workflow subagent)
Phase 2: 비판적 검토
  ↓ (plan-reviewer subagent)
점수 >= 8.0?
  ├─ Yes → Phase 5 (확정)
  └─ No → Phase 3/4 (개선)
      ↓
Phase 3: 의사결정 (필요 시)
  ↓ (decision-maker subagent)
Phase 4: 개선 및 재검토
  ↓ (plan-workflow + plan-reviewer)
반복 횟수 체크
  ├─ < 3회 → Phase 2로 돌아감
  └─ >= 3회 → Phase 5 (확정)
      ↓
Phase 5: 최종 확정 및 요약
```

---

**Begin with Phase 1: 계획 초안 작성**

작업 내용: $ARGUMENTS
