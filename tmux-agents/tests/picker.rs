mod support;

use ratatui::crossterm::event::KeyCode;
use support::{Picker, key};

#[test]
fn empty_list_shows_message_and_q_quits() {
    let mut picker = Picker::new(Vec::new());

    picker.run(vec![key(KeyCode::Char('q'))]).unwrap();

    assert!(
        picker
            .screen()
            .contains("No Claude Code sessions in this tmux server")
    );
    assert!(picker.tmux.focused().is_empty());
}
