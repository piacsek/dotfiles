use ratatui::Frame;
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{List, ListItem, Paragraph};

use crate::agents::Agent;
use crate::app::App;

pub fn draw(frame: &mut Frame, app: &mut App) {
    if app.agents.is_empty() {
        frame.render_widget(
            Paragraph::new("No Claude Code sessions in this tmux server"),
            frame.area(),
        );
        return;
    }
    let items: Vec<ListItem> = app.agents.iter().map(row).collect();
    let list = List::new(items).highlight_symbol("> ");
    frame.render_stateful_widget(list, frame.area(), &mut app.list);
}

fn row(agent: &Agent) -> ListItem<'_> {
    let mut spans = vec![Span::styled(
        agent.label.as_str(),
        Style::default().add_modifier(Modifier::BOLD),
    )];
    if let Some(title) = &agent.title {
        spans.push(Span::raw("  "));
        spans.push(Span::styled(
            title.as_str(),
            Style::default().add_modifier(Modifier::DIM),
        ));
    }
    ListItem::new(Line::from(spans))
}
