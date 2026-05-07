# Data model — <Discovery title>

```mermaid
erDiagram
  ENTITY_A ||--o{ ENTITY_B : has
  ENTITY_A {
    uuid id PK
    string name
  }
  ENTITY_B {
    uuid id PK
    uuid entity_a_id FK
  }
```

## Notes

### New tables / columns
- ...

### Existing tables touched
- ...

### Migration considerations
- Backfill strategy
- NOT NULL columns and defaults
- Index changes
- Lock impact on hot tables
