use ratatui::Frame;
use ratatui::layout::{Constraint, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{List, ListItem, Paragraph};

use crate::agents::Agent;
use crate::app::{App, Mode, visible_agents};
use crate::state::{State, WORD_WIDTH};

const HELP_HINT: &str = "press ? for keybindings";

pub fn draw(frame: &mut Frame, app: &mut App) {
    let [body, footer] =
        Layout::vertical([Constraint::Min(1), Constraint::Length(1)]).areas(frame.area());
    if app.mode == Mode::Help {
        draw_help(frame, body);
    } else if app.agents.is_empty() {
        draw_empty(frame, body);
    } else {
        draw_list(frame, body, app);
    }
    draw_footer(frame, footer, app);
}

fn draw_empty(frame: &mut Frame, area: Rect) {
    let text = vec![
        Line::from("No Claude Code sessions in this tmux server"),
        Line::from(""),
        Line::from(Span::styled("n new Claude pane  q close", dim())),
    ];
    frame.render_widget(Paragraph::new(text), area);
}

const KEYS: [(&str, &str); 7] = [
    ("j/k ↓/↑", "move"),
    ("gg / G", "first / last"),
    ("/", "filter, Esc clears"),
    ("Enter", "focus pane"),
    ("n", "new Claude pane"),
    ("q / Esc", "close"),
    ("?", "toggle this help"),
];

fn draw_help(frame: &mut Frame, area: Rect) {
    let width = KEYS
        .iter()
        .map(|(k, _)| k.chars().count())
        .max()
        .unwrap_or(0);
    let lines: Vec<Line> = KEYS
        .iter()
        .map(|(key, what)| {
            Line::from(vec![
                Span::styled(
                    format!("{key:<width$}"),
                    Style::default().add_modifier(Modifier::BOLD),
                ),
                Span::raw("  "),
                Span::styled(*what, dim()),
            ])
        })
        .collect();
    frame.render_widget(Paragraph::new(lines), area);
}

fn draw_list(frame: &mut Frame, area: Rect, app: &mut App) {
    let visible = visible_agents(&app.agents, app.filter());
    let label_width = visible
        .iter()
        .map(|agent| agent.label.chars().count())
        .max()
        .unwrap_or(0);
    let items: Vec<ListItem> = visible
        .into_iter()
        .map(|agent| row(agent, label_width))
        .collect();
    let list = List::new(items).highlight_symbol("> ");
    frame.render_stateful_widget(list, area, &mut app.list);
}

fn draw_footer(frame: &mut Frame, area: Rect, app: &App) {
    let hint_width = HELP_HINT.chars().count() as u16;
    let [left, right] =
        Layout::horizontal([Constraint::Min(1), Constraint::Length(hint_width)]).areas(area);
    match &app.mode {
        Mode::Help => {
            let version = format!("tmux-agents v{}", env!("CARGO_PKG_VERSION"));
            frame.render_widget(Paragraph::new(Span::styled(version, dim())), left);
        }
        Mode::Filter(query) => frame.render_widget(Paragraph::new(format!("/{query}")), left),
        Mode::Normal => {}
    }
    frame.render_widget(
        Paragraph::new(Span::styled(HELP_HINT, dim())).right_aligned(),
        right,
    );
}

fn row(agent: &Agent, label_width: usize) -> ListItem<'_> {
    let state = State::from(agent.status);
    let mut spans = vec![
        Span::styled(state.glyph(), state.style()),
        Span::raw(" "),
        Span::styled(format!("{:<WORD_WIDTH$}", state.word()), dim()),
        Span::raw("  "),
        Span::styled(
            format!("{:<label_width$}", agent.label),
            Style::default().add_modifier(Modifier::BOLD),
        ),
    ];
    if let Some(title) = &agent.title {
        spans.push(Span::raw("  "));
        spans.push(Span::styled(title.as_str(), dim()));
    }
    ListItem::new(Line::from(spans))
}

fn dim() -> Style {
    Style::default().add_modifier(Modifier::DIM)
}
