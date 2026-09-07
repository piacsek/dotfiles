use ratatui::Frame;
use ratatui::layout::{Constraint, Layout};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{List, ListItem, Paragraph};

use crate::agents::Agent;
use crate::app::{App, visible_agents};
use crate::state::{State, WORD_WIDTH};

pub fn draw(frame: &mut Frame, app: &mut App) {
    if app.agents.is_empty() {
        let dim = Style::default().add_modifier(Modifier::DIM);
        let text = vec![
            Line::from("No Claude Code sessions in this tmux server"),
            Line::from(""),
            Line::from(Span::styled("n new Claude pane  q close", dim)),
        ];
        frame.render_widget(Paragraph::new(text), frame.area());
        return;
    }
    let [list_area, footer_area] =
        Layout::vertical([Constraint::Min(1), Constraint::Length(1)]).areas(frame.area());
    let visible = visible_agents(&app.agents, app.filter.as_deref());
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
    frame.render_stateful_widget(list, list_area, &mut app.list);
    if let Some(query) = &app.filter {
        frame.render_widget(Paragraph::new(format!("/{query}")), footer_area);
    }
}

fn row(agent: &Agent, label_width: usize) -> ListItem<'_> {
    let state = State::from(agent.status);
    let dim = Style::default().add_modifier(Modifier::DIM);
    let mut spans = vec![
        Span::styled(state.glyph(), state.style()),
        Span::raw(" "),
        Span::styled(format!("{:<WORD_WIDTH$}", state.word()), dim),
        Span::raw("  "),
        Span::styled(
            format!("{:<label_width$}", agent.label),
            Style::default().add_modifier(Modifier::BOLD),
        ),
    ];
    if let Some(title) = &agent.title {
        spans.push(Span::raw("  "));
        spans.push(Span::styled(title.as_str(), dim));
    }
    ListItem::new(Line::from(spans))
}
