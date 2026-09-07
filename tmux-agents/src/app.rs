use std::io;

use ratatui::Terminal;
use ratatui::backend::Backend;
use ratatui::crossterm::event::{Event, KeyCode, KeyEvent};
use ratatui::widgets::ListState;

use crate::agents::Agent;
use crate::tmux::Tmux;
use crate::ui;

#[derive(Debug, PartialEq, Eq)]
pub enum Action {
    Continue,
    Quit,
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
            KeyCode::Char('q') => Action::Quit,
            _ => Action::Continue,
        }
    }
}

pub fn run<B, T>(
    terminal: &mut Terminal<B>,
    app: &mut App,
    events: impl Iterator<Item = io::Result<Event>>,
    _tmux: &T,
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
                Action::Continue => {}
            }
        }
    }
    Ok(())
}
