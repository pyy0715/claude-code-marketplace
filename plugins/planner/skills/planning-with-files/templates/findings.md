# Findings Log
<!-- 
  WHAT: 프로젝트 전반에서 발견한 지식을 축적하는 지식 베이스
  WHY: 모델은 50회 도구 호출 후 이전 발견을 잊음. 이 파일에 기록된 내용은 컨텍스트에 자동 주입되어 지식이 보존됨
  WHEN: PreToolUse 훅으로 모든 Write/Edit/Bash 작업 전 자동 주입
  EXAMPLE: "utils/auth.ts는 JWT 검증 로직 포함" 같은 발견을 기록하면, 나중에 인증 관련 작업 시 자동으로 참조 가능
-->

**2-Action Rule 준수**: 매 2회 도구 호출 후 이 파일 업데이트 필수
<!-- 
  WHAT: 지식 손실을 방지하기 위한 엄격한 업데이트 규칙
  WHY: 발견을 즉시 기록하지 않으면 컨텍스트 밖으로 사라짐
  WHEN: Read, Grep, Glob 등으로 무언가 발견 → 2회 도구 호출 내 기록
  EXAMPLE: 
    1. Grep으로 API 엔드포인트 발견
    2. Read로 구현 확인
    → 즉시 findings.md에 "API 엔드포인트는 routes/api.ts에 Express Router로 구현" 기록
-->

---

## Architecture
<!-- 프로젝트 구조, 주요 패턴, 기술 스택 -->

### Key Components
- **Component Name**: Brief description and location

### Technical Stack
- Language/Framework: Version and key characteristics

---

## Code Patterns
<!-- 프로젝트 내에서 발견한 코딩 패턴과 컨벤션 -->

### Naming Conventions
- Pattern observed in codebase

### Common Patterns
- Pattern description and examples

---

## Dependencies
<!-- 외부 라이브러리, 내부 모듈 간 의존성 -->

### External Libraries
- **Library Name**: Purpose and usage notes

### Internal Dependencies
- Module relationships and import patterns

---

## Gotchas
<!-- 주의사항, 알려진 이슈, 회피해야 할 패턴 -->

- **Issue**: Description and workaround

---

## Quick Reference
<!-- 자주 참조하는 파일, 함수, 설정 -->

- `file/path.ts:line`: Brief description of what's there
