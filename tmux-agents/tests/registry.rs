use std::fs;
use std::path::PathBuf;

use tmux_agents::registry::{Kind, SessionRecord, Status, load};

const REAL_SAMPLE: &str = r#"{"pid":27756,"sessionId":"dd9b863e-48ca-4cd8-a0f4-bc3c204a220c","cwd":"/Users/piacsek/dotfiles","startedAt":1788798199062,"procStart":"Mon Sep  7 16:23:16 2026","version":"2.1.263","peerProtocol":1,"peerFeatures":["notify_idle","reply_across_default_dirs","artifact_yield"],"kind":"interactive","entrypoint":"cli","pidDomain":"darwin","tmux":"dotfiles:@7.%53","messagingSocketPath":"/tmp/cc-socks/27756.sock","name":"dotfiles-d8","nameSource":"derived","nameSince":1788798199063,"status":"busy","updatedAt":1788804089018,"statusUpdatedAt":1788804089018}"#;

#[test]
fn load_parses_a_real_session_file_ignoring_unknown_fields() {
    let dir = tempfile::tempdir().unwrap();
    fs::write(dir.path().join("27756.json"), REAL_SAMPLE).unwrap();

    let records = load(dir.path());

    assert_eq!(
        records,
        vec![SessionRecord {
            pid: 27756,
            cwd: PathBuf::from("/Users/piacsek/dotfiles"),
            name: Some("dotfiles-d8".to_string()),
            kind: Kind::Interactive,
            status: Status::Busy,
            tmux: Some("dotfiles:@7.%53".to_string()),
        }]
    );
}

#[test]
fn load_skips_non_json_files_and_malformed_json() {
    let dir = tempfile::tempdir().unwrap();
    fs::write(dir.path().join("27756.json.tmp"), REAL_SAMPLE).unwrap();
    fs::write(
        dir.path().join("27756.abc.key"),
        r#"{"peerToken":"x","procStart":"y","pidDomain":"darwin"}"#,
    )
    .unwrap();
    fs::write(dir.path().join("99.json"), "{not json").unwrap();
    fs::write(dir.path().join("1.json"), REAL_SAMPLE).unwrap();

    let records = load(dir.path());

    assert_eq!(records.len(), 1);
}
