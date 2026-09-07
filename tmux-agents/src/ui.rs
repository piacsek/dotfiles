use ratatui::Frame;
use ratatui::widgets::{List, ListItem, Paragraph};

use crate::app::App;

pub fn draw(frame: &mut Frame, app: &mut App) {
    if app.agents.is_empty() {
        frame.render_widget(
            Paragraph::new("No Claude Code sessions in this tmux server"),
            frame.area(),
        );
        return;
    }
    let items: Vec<ListItem> = app
        .agents
        .iter()
        .map(|agent| ListItem::new(agent.label.as_str()))
        .collect();
    let list = List::new(items).highlight_symbol("> ");
    frame.render_stateful_widget(list, frame.area(), &mut app.list);
}
