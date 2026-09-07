use std::io;

use ratatui::Terminal;
use ratatui::backend::Backend;
use ratatui::crossterm::event::{Event, KeyCode, KeyEvent};
use ratatui::widgets::ListState;

use crate::agents::Agent;
use crate::tmux::{PaneId, Tmux};
use crate::ui;

#[derive(Debug, PartialEq, Eq)]
pub enum Action {
    Continue,
    Quit,
    Focus(PaneId),
}

pub struct App {
    pub agents: Vec<Agent>,
    pub list: ListState,
}

impl App {
    pub fn new(agents: Vec<Agent>) -> Self {
        let list = ListState::default().with_selected(Some(0));
        Self { agents, list }
    }

    pub fn handle_key(&mut self, key: KeyEvent) -> Action {
        match key.code {
            KeyCode::Char('q') => return Action::Quit,
            KeyCode::Enter => {
                if let Some(agent) = self.list.selected().and_then(|i| self.agents.get(i)) {
                    return Action::Focus(agent.pane.clone());
                }
            }
            KeyCode::Char('j') | KeyCode::Down => self.list.select_next(),
            KeyCode::Char('k') | KeyCode::Up => self.list.select_previous(),
            _ => {}
        }
        Action::Continue
    }
}

pub fn run<B, T>(
    terminal: &mut Terminal<B>,
    app: &mut App,
    events: impl Iterator<Item = io::Result<Event>>,
    tmux: &T,
) -> io::Result<()>
where
    B: Backend,
    B::Error: Send + Sync + 'static,
    T: Tmux,
{
    for event in events {
        terminal
            .draw(|frame| ui::draw(frame, app))
            .map_err(io::Error::other)?;
        if let Event::Key(key) = event? {
            match app.handle_key(key) {
                Action::Quit => return Ok(()),
                Action::Focus(pane) => return tmux.focus(&pane),
                Action::Continue => {}
            }
        }
    }
    Ok(())
}
