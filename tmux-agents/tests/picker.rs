mod support;

use ratatui::crossterm::event::KeyCode;
use ratatui::style::{Color, Modifier};
use support::{Picker, agent, agent_with_status, ctrl, key, tick};
use tmux_agents::registry::Status;
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
    assert!(rows[0].starts_with("> ○ idle     dotfiles"), "{screen}");
    assert!(rows[1].starts_with("  ○ idle     ws-common"), "{screen}");
}

#[test]
fn j_and_down_move_highlight_down() {
    let agents = || vec![agent("a", "%1"), agent("b", "%2"), agent("c", "%3")];

    let mut picker = Picker::new(agents());
    picker
        .run(vec![key(KeyCode::Char('j')), key(KeyCode::Char('q'))])
        .unwrap();
    assert!(
        picker
            .screen()
            .lines()
            .nth(1)
            .unwrap()
            .starts_with("> ○ idle     b")
    );

    let mut picker = Picker::new(agents());
    picker
        .run(vec![
            key(KeyCode::Down),
            key(KeyCode::Down),
            key(KeyCode::Char('q')),
        ])
        .unwrap();
    assert!(
        picker
            .screen()
            .lines()
            .nth(2)
            .unwrap()
            .starts_with("> ○ idle     c")
    );
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
        screen.lines().next().unwrap().starts_with("> ○ idle     a"),
        "{screen}"
    );
    assert!(
        screen.lines().nth(1).unwrap().starts_with("  ○ idle     b"),
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
            .starts_with("> ○ idle     dotfiles   Tmux Claude Code session picker"),
        "{screen}"
    );
    assert_eq!(
        screen.lines().nth(1).unwrap().trim_end(),
        "  ○ idle     ws-common"
    );
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

    assert!(
        picker
            .screen()
            .lines()
            .nth(2)
            .unwrap()
            .starts_with("> ○ idle     c")
    );
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
    assert!(
        picker
            .screen()
            .lines()
            .next()
            .unwrap()
            .starts_with("> ○ idle     a")
    );

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
    assert!(
        picker
            .screen()
            .lines()
            .nth(2)
            .unwrap()
            .starts_with("> ○ idle     c"),
        "{}",
        picker.screen()
    );
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
    let rows: Vec<&str> = screen
        .lines()
        .map(str::trim_end)
        .filter(|l| !l.is_empty())
        .collect();
    assert_eq!(rows, vec!["> ○ idle     ws-common", "/Ws"], "{screen}");
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
    assert!(
        screen.contains("> ○ idle     dotfiles  Fix the Picker"),
        "{screen}"
    );
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
    assert!(screen.contains("> ○ idle     ws-common"), "{screen}");
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

#[test]
fn enter_in_filter_mode_focuses_the_selected_visible_row() {
    let mut picker = Picker::new(vec![
        agent("dotfiles", "%1"),
        agent("ws-common", "%2"),
        agent("ws-start", "%3"),
    ]);

    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('w')),
            key(KeyCode::Down),
            key(KeyCode::Enter),
        ])
        .unwrap();

    assert_eq!(picker.tmux.focused(), vec![PaneId("%3".to_string())]);
}

#[test]
fn starting_a_filter_moves_the_highlight_to_the_first_match() {
    let mut picker = Picker::new(vec![
        agent("dotfiles", "%1"),
        agent("ws-common", "%2"),
        agent("ws-start", "%3"),
    ]);

    picker
        .run(vec![
            key(KeyCode::Char('G')),
            key(KeyCode::Char('/')),
            key(KeyCode::Char('w')),
        ])
        .unwrap();

    let screen = picker.screen();
    assert!(
        screen
            .lines()
            .next()
            .unwrap()
            .starts_with("> ○ idle     ws-common"),
        "{screen}"
    );
}

#[test]
fn rows_show_a_state_glyph_and_word() {
    let mut picker = Picker::new(vec![
        agent_with_status("a", "%1", Status::Busy),
        agent_with_status("b", "%2", Status::Shell),
        agent_with_status("c", "%3", Status::Waiting),
        agent_with_status("d", "%4", Status::Idle),
        agent_with_status("e", "%5", Status::Unknown),
    ]);

    picker.run(Vec::new()).unwrap();

    let screen = picker.screen();
    let rows: Vec<&str> = screen.lines().map(str::trim_end).take(5).collect();
    assert_eq!(
        rows,
        vec![
            "> ● working  a",
            "  ● working  b",
            "  ◉ blocked  c",
            "  ○ idle     d",
            "  ○ ?        e",
        ],
        "{screen}"
    );
}

#[test]
fn state_dots_use_the_ansi_palette_and_words_are_dim() {
    let mut picker = Picker::new(vec![
        agent_with_status("a", "%1", Status::Busy),
        agent_with_status("b", "%2", Status::Waiting),
        agent_with_status("c", "%3", Status::Idle),
        agent_with_status("d", "%4", Status::Unknown),
    ]);

    picker.run(Vec::new()).unwrap();

    let dot = |y| picker.cell(2, y);
    assert_eq!(dot(0).fg, Color::Yellow);
    assert_eq!(dot(1).fg, Color::Red);
    assert_eq!(dot(2).fg, Color::Reset);
    assert!(dot(2).modifier.contains(Modifier::DIM));
    assert_eq!(dot(3).fg, Color::DarkGray);
    let word_style = picker.cell(4, 0);
    assert_eq!(word_style.symbol(), "w");
    assert!(word_style.modifier.contains(Modifier::DIM));
}

#[test]
fn a_tick_refreshes_the_rows_from_the_source() {
    let mut picker = Picker::new(vec![agent("a", "%1")]);
    picker.next_refresh_returns(vec![agent("a", "%1"), agent("b", "%2")]);

    picker.run(vec![tick()]).unwrap();

    let screen = picker.screen();
    assert!(screen.lines().nth(1).unwrap().contains("b"), "{screen}");
}

fn agent_with_pid(label: &str, pane: &str, pid: i32) -> tmux_agents::agents::Agent {
    tmux_agents::agents::Agent {
        pid,
        ..agent(label, pane)
    }
}

#[test]
fn refresh_keeps_the_selected_agent_when_rows_reorder() {
    let a = agent_with_pid("a", "%1", 1);
    let b = agent_with_pid("b", "%2", 2);
    let mut picker = Picker::new(vec![a.clone(), b.clone()]);
    picker.next_refresh_returns(vec![b, a]);

    picker
        .run(vec![key(KeyCode::Char('j')), tick(), key(KeyCode::Enter)])
        .unwrap();

    assert_eq!(picker.tmux.focused(), vec![PaneId("%2".to_string())]);
    assert!(
        picker
            .screen()
            .lines()
            .next()
            .unwrap()
            .starts_with("> ○ idle     b")
    );
}

#[test]
fn refresh_falls_back_to_the_first_row_when_the_selected_agent_is_gone() {
    let a = agent_with_pid("a", "%1", 1);
    let b = agent_with_pid("b", "%2", 2);
    let mut picker = Picker::new(vec![a.clone(), b]);
    picker.next_refresh_returns(vec![a]);

    picker
        .run(vec![key(KeyCode::Char('j')), tick(), key(KeyCode::Enter)])
        .unwrap();

    assert_eq!(picker.tmux.focused(), vec![PaneId("%1".to_string())]);
}

#[test]
fn filter_still_applies_after_a_refresh() {
    let mut picker = Picker::new(vec![agent("dotfiles", "%1"), agent("ws-common", "%2")]);
    picker.next_refresh_returns(vec![
        agent("dotfiles", "%1"),
        agent("ws-common", "%2"),
        agent("ws-start", "%3"),
    ]);

    picker
        .run(vec![
            key(KeyCode::Char('/')),
            key(KeyCode::Char('w')),
            tick(),
        ])
        .unwrap();

    let screen = picker.screen();
    assert!(!screen.contains("dotfiles"), "{screen}");
    assert!(screen.contains("ws-start"), "{screen}");
    assert!(screen.contains("/w"), "{screen}");
}

#[test]
fn state_word_precedes_the_dir_and_dir_and_title_columns_are_aligned() {
    let mut short = agent_with_status("a", "%1", Status::Idle);
    short.title = Some("T1".to_string());
    let mut long = agent_with_status("bb-long", "%2", Status::Busy);
    long.title = Some("T2".to_string());
    let mut picker = Picker::new(vec![short, long]);

    picker.run(Vec::new()).unwrap();

    let screen = picker.screen();
    let rows: Vec<&str> = screen.lines().map(str::trim_end).take(2).collect();
    assert_eq!(
        rows,
        vec!["> ○ idle     a        T1", "  ● working  bb-long  T2"],
        "{screen}"
    );
}

#[test]
fn empty_list_shows_a_hint_for_starting_a_session() {
    let mut picker = Picker::new(Vec::new());

    picker.run(Vec::new()).unwrap();

    let screen = picker.screen();
    assert!(
        screen.contains("No Claude Code sessions in this tmux server"),
        "{screen}"
    );
    assert!(screen.contains("n new Claude pane  q close"), "{screen}");
}

#[test]
fn n_requests_a_new_claude_pane_and_closes() {
    let mut picker = Picker::new(Vec::new());
    picker
        .run(vec![key(KeyCode::Char('n')), key(KeyCode::Enter)])
        .unwrap();
    assert_eq!(picker.tmux.new_panes_requested(), 1);

    let mut picker = Picker::new(vec![agent("a", "%1")]);
    picker
        .run(vec![key(KeyCode::Char('n')), key(KeyCode::Enter)])
        .unwrap();
    assert_eq!(picker.tmux.new_panes_requested(), 1);
    assert!(picker.tmux.focused().is_empty());
}
