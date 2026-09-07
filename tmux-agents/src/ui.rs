use ratatui::Frame;
use ratatui::widgets::Paragraph;

use crate::app::App;

pub fn draw(frame: &mut Frame, app: &mut App) {
    if app.agents.is_empty() {
        frame.render_widget(
            Paragraph::new("No Claude Code sessions in this tmux server"),
            frame.area(),
        );
    }
}
