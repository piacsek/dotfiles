mod support;

use ratatui::crossterm::event::KeyCode;
use support::{Picker, agent, ctrl, key};
use tmux_agents::tmux::PaneId;

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

#[test]
fn rows_show_labels_with_first_highlighted() {
    let mut picker = Picker::new(vec![agent("dotfiles", "%1"), agent("ws-common", "%2")]);

    picker.run(vec![key(KeyCode::Char('q'))]).unwrap();

    let screen = picker.screen();
    let rows: Vec<&str> = screen.lines().collect();
    assert!(rows[0].starts_with("> dotfiles"), "{screen}");
    assert!(rows[1].starts_with("  ws-common"), "{screen}");
}

#[test]
fn j_and_down_move_highlight_down() {
    let agents = || vec![agent("a", "%1"), agent("b", "%2"), agent("c", "%3")];

    let mut picker = Picker::new(agents());
    picker
        .run(vec![key(KeyCode::Char('j')), key(KeyCode::Char('q'))])
        .unwrap();
    assert!(picker.screen().lines().nth(1).unwrap().starts_with("> b"));

    let mut picker = Picker::new(agents());
    picker
        .run(vec![
            key(KeyCode::Down),
            key(KeyCode::Down),
            key(KeyCode::Char('q')),
        ])
        .unwrap();
    assert!(picker.screen().lines().nth(2).unwrap().starts_with("> c"));
}

#[test]
fn k_and_up_move_highlight_up_and_clamp_at_both_ends() {
    let mut picker = Picker::new(vec![agent("a", "%1"), agent("b", "%2")]);

    picker
        .run(vec![
            key(KeyCode::Up),
            key(KeyCode::Char('j')),
            key(KeyCode::Char('j')),
            key(KeyCode::Char('j')),
            key(KeyCode::Char('k')),
            key(KeyCode::Char('q')),
        ])
        .unwrap();

    let screen = picker.screen();
    assert!(
        screen.lines().next().unwrap().starts_with("> a"),
        "{screen}"
    );
    assert!(
        screen.lines().nth(1).unwrap().starts_with("  b"),
        "{screen}"
    );
}

#[test]
fn enter_focuses_selected_pane_and_exits() {
    let mut picker = Picker::new(vec![agent("a", "%1"), agent("b", "%53")]);

    picker
        .run(vec![
            key(KeyCode::Char('j')),
            key(KeyCode::Enter),
            key(KeyCode::Char('j')),
        ])
        .unwrap();

    assert_eq!(picker.tmux.focused(), vec![PaneId("%53".to_string())]);
    assert_eq!(picker.app.list.selected(), Some(1));
}

#[test]
fn enter_on_empty_list_does_nothing() {
    let mut picker = Picker::new(Vec::new());

    picker
        .run(vec![key(KeyCode::Enter), key(KeyCode::Char('q'))])
        .unwrap();

    assert!(picker.tmux.focused().is_empty());
}

#[test]
fn esc_and_ctrl_c_quit_without_focusing() {
    let mut picker = Picker::new(vec![agent("a", "%1")]);
    picker
        .run(vec![key(KeyCode::Esc), key(KeyCode::Enter)])
        .unwrap();
    assert!(picker.tmux.focused().is_empty());

    let mut picker = Picker::new(vec![agent("a", "%1")]);
    picker.run(vec![ctrl('c'), key(KeyCode::Enter)]).unwrap();
    assert!(picker.tmux.focused().is_empty());
}

#[test]
fn row_shows_title_after_label_when_present() {
    let mut titled = agent("dotfiles", "%1");
    titled.title = Some("Tmux Claude Code session picker".to_string());
    let mut picker = Picker::new(vec![titled, agent("ws-common", "%2")]);

    picker.run(vec![key(KeyCode::Char('q'))]).unwrap();

    let screen = picker.screen();
    assert!(
        screen
            .lines()
            .next()
            .unwrap()
            .starts_with("> dotfiles  Tmux Claude Code session picker"),
        "{screen}"
    );
    assert_eq!(screen.lines().nth(1).unwrap().trim_end(), "  ws-common");
}

#[test]
fn screen_is_drawn_before_any_key_arrives() {
    let mut picker = Picker::new(vec![agent("dotfiles", "%1")]);

    picker.run(Vec::new()).unwrap();

    assert!(picker.screen().contains("dotfiles"), "{}", picker.screen());
}

#[test]
fn shift_g_jumps_to_the_last_row() {
    let mut picker = Picker::new(vec![agent("a", "%1"), agent("b", "%2"), agent("c", "%3")]);

    picker
        .run(vec![key(KeyCode::Char('G')), key(KeyCode::Char('q'))])
        .unwrap();

    assert!(picker.screen().lines().nth(2).unwrap().starts_with("> c"));
}

#[test]
fn gg_jumps_to_the_first_row_but_a_lone_g_does_nothing() {
    let three = || vec![agent("a", "%1"), agent("b", "%2"), agent("c", "%3")];

    let mut picker = Picker::new(three());
    picker
        .run(vec![
            key(KeyCode::Char('G')),
            key(KeyCode::Char('g')),
            key(KeyCode::Char('g')),
            key(KeyCode::Char('q')),
        ])
        .unwrap();
    assert!(picker.screen().lines().next().unwrap().starts_with("> a"));

    let mut picker = Picker::new(three());
    picker
        .run(vec![
            key(KeyCode::Char('G')),
            key(KeyCode::Char('g')),
            key(KeyCode::Char('j')),
            key(KeyCode::Char('g')),
            key(KeyCode::Char('q')),
        ])
        .unwrap();
    assert!(picker.screen().lines().nth(2).unwrap().starts_with("> c"), "{}", picker.screen());
}

#[test]
fn slash_filters_rows_by_label_and_shows_the_query() {
    let mut picker = Picker::new(vec![
        agent("dotfiles", "%1"),
        agent("ws-common", "%2"),
        agent("scintilla", "%3"),
    ]);

    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('W')),
            key(KeyCode::Char('s')),
        ])
        .unwrap();

    let screen = picker.screen();
    let rows: Vec<&str> = screen.lines().map(str::trim_end).filter(|l| !l.is_empty()).collect();
    assert_eq!(rows, vec!["> ws-common", "/Ws"], "{screen}");
}

#[test]
fn filter_also_matches_the_title() {
    let mut titled = agent("dotfiles", "%1");
    titled.title = Some("Fix the Picker".to_string());
    let mut picker = Picker::new(vec![titled, agent("ws-common", "%2")]);

    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('p')),
            key(KeyCode::Char('i')),
            key(KeyCode::Char('c')),
        ])
        .unwrap();

    let screen = picker.screen();
    assert!(screen.contains("> dotfiles  Fix the Picker"), "{screen}");
    assert!(!screen.contains("ws-common"), "{screen}");
}

#[test]
fn backspace_edits_the_query_and_esc_clears_the_filter_without_quitting() {
    let agents = || vec![agent("dotfiles", "%1"), agent("ws-common", "%2")];

    let mut picker = Picker::new(agents());
    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('w')),
            key(KeyCode::Char('x')),
            key(KeyCode::Backspace),
        ])
        .unwrap();
    let screen = picker.screen();
    assert!(screen.contains("> ws-common"), "{screen}");
    assert!(screen.contains("/w"), "{screen}");
    assert!(!screen.contains("/wx"), "{screen}");

    let mut picker = Picker::new(agents());
    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('w')),
            key(KeyCode::Esc),
            key(KeyCode::Char('j')),
            key(KeyCode::Enter),
        ])
        .unwrap();
    let screen = picker.screen();
    assert!(screen.contains("dotfiles"), "{screen}");
    assert!(!screen.contains('/'), "{screen}");
    assert_eq!(picker.tmux.focused(), vec![PaneId("%2".to_string())]);
}
