use std::io;

use ratatui::Terminal;
use ratatui::backend::Backend;
use ratatui::crossterm::event::{Event, KeyCode, KeyEvent, KeyModifiers};
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
    pub filter: Option<String>,
    pending_g: bool,
}

impl App {
    pub fn new(agents: Vec<Agent>) -> Self {
        let list = ListState::default().with_selected(Some(0));
        Self {
            agents,
            list,
            filter: None,
            pending_g: false,
        }
    }

    pub fn visible(&self) -> Vec<&Agent> {
        visible_agents(&self.agents, self.filter.as_deref())
    }

    pub fn handle_key(&mut self, key: KeyEvent) -> Action {
        if key.modifiers.contains(KeyModifiers::CONTROL) && key.code == KeyCode::Char('c') {
            return Action::Quit;
        }
        if let Some(query) = &mut self.filter
            && let KeyCode::Char(c) = key.code
        {
            query.push(c);
            return Action::Continue;
        }
        let pending_g = std::mem::take(&mut self.pending_g);
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Action::Quit,
            KeyCode::Char('/') => self.filter = Some(String::new()),
            KeyCode::Char('g') if pending_g => self.list.select_first(),
            KeyCode::Char('g') => self.pending_g = true,
            KeyCode::Enter => {
                if let Some(agent) = self.list.selected().and_then(|i| self.agents.get(i)) {
                    return Action::Focus(agent.pane.clone());
                }
            }
            KeyCode::Char('j') | KeyCode::Down => self.list.select_next(),
            KeyCode::Char('k') | KeyCode::Up => self.list.select_previous(),
            KeyCode::Char('G') => self.list.select_last(),
            _ => {}
        }
        Action::Continue
    }
}

pub fn visible_agents<'a>(agents: &'a [Agent], filter: Option<&str>) -> Vec<&'a Agent> {
    let query = filter.unwrap_or("").to_lowercase();
    agents
        .iter()
        .filter(|agent| {
            agent.label.to_lowercase().contains(&query)
                || agent
                    .title
                    .as_deref()
                    .is_some_and(|t| t.to_lowercase().contains(&query))
        })
        .collect()
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
    let mut events = events;
    loop {
        terminal
            .draw(|frame| ui::draw(frame, app))
            .map_err(io::Error::other)?;
        let Some(event) = events.next() else {
            return Ok(());
        };
        if let Event::Key(key) = event? {
            match app.handle_key(key) {
                Action::Quit => return Ok(()),
                Action::Focus(pane) => return tmux.focus(&pane),
                Action::Continue => {}
            }
        }
    }
}
