# Progress Log
<!-- 
  WHAT: 세션별 작업 기록과 오류 로그를 시간순으로 추적
  WHY: 무엇을 시도했고, 무엇이 실패했고, 어떻게 해결했는지 기록하여 반복 실수 방지
  WHEN: 각 작업 세션 후 수동 업데이트 (자동 주입되지 않음 - 필요시 수동 참조)
  EXAMPLE: "2025-01-12 14:30 - API 통합 시도 → CORS 에러 → middleware 추가로 해결"
-->

---

## Session Timeline
<!-- 시간순 작업 기록 -->

### [DATE] - [SESSION_TITLE]
**Goal**: What you aimed to accomplish

**Actions**:
- Action taken and result
- Next action and result

**Outcome**: What was achieved or blocked

---

## Error Log
<!-- 
  WHAT: 발생한 오류와 해결 방법을 체계적으로 기록
  WHY: 같은 오류를 반복하지 않고, 해결 패턴을 학습
  WHEN: 오류 발생 시마다 즉시 기록
-->

### [ERROR_TYPE] - [DATE]
**Context**: What you were trying to do

**Error**: 
```
Error message or description
```

**Solution**: How it was resolved

**Prevention**: How to avoid this in future

---

## 3-Strike Error Protocol
<!-- 
  WHAT: 같은 오류를 3회 반복하면 강제 중단하고 전략 재검토
  WHY: 무한 시행착오 방지, 근본 원인 분석 강제
  WHEN: 동일한 에러가 3회 발생 → 즉시 중단 → task_plan.md와 findings.md 재검토
  EXAMPLE: 
    Strike 1: "Cannot find module 'foo'" 
    Strike 2: "Cannot find module 'foo'" (다른 접근 시도)
    Strike 3: → STOP → 모듈 시스템 자체 재검토 필요
-->

**Current Strikes**: 0/3

---

## 5-Question Check
<!-- 
  WHAT: 각 세션 종료 전 필수 점검 항목
  WHY: 작업이 실제로 완료되었는지, 다음 세션에서 혼란이 없는지 확인
  WHEN: 세션 종료 전 또는 Stop 훅 실행 시
-->

Before ending session, answer these:

1. **Is the current task fully complete?**
   - [ ] Yes / [ ] No - If no, what remains?

2. **Are findings.md and task_plan.md updated?**
   - [ ] Yes / [ ] No - What needs updating?

3. **Are there any known blockers for the next session?**
   - [ ] None / [ ] Yes - Document blocker

4. **Is the codebase in a stable state?**
   - [ ] Yes / [ ] No - What needs fixing?

5. **What is the exact next action?**
   - Answer: [Specific next step]

---

## Session Handoff
<!-- 다음 세션을 위한 명확한 출발점 -->

**Resume From**: [Exact task and file location]  
**Context Needed**: [Any specific context to load]  
**Known Issues**: [Any blockers or warnings]
