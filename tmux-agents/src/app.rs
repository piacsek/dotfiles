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
        if self.filter.is_some() {
            match key.code {
                KeyCode::Char(c) => return self.edit_filter(|q| q.push(c)),
                KeyCode::Backspace => {
                    return self.edit_filter(|q| {
                        q.pop();
                    });
                }
                KeyCode::Esc => {
                    self.filter = None;
                    return Action::Continue;
                }
                _ => {}
            }
        }
        let pending_g = std::mem::take(&mut self.pending_g);
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Action::Quit,
            KeyCode::Char('/') => self.filter = Some(String::new()),
            KeyCode::Char('g') if pending_g => self.list.select_first(),
            KeyCode::Char('g') => self.pending_g = true,
            KeyCode::Enter => {
                if let Some(agent) = self
                    .list
                    .selected()
                    .and_then(|i| self.visible().get(i).copied())
                {
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

impl App {
    fn edit_filter(&mut self, edit: impl FnOnce(&mut String)) -> Action {
        if let Some(query) = &mut self.filter {
            edit(query);
        }
        self.list.select_first();
        Action::Continue
    }
}

pub fn visible_agents<'a>(agents: &'a [Agent], filter: Option<&str>) -> Vec<&'a Agent> {
    let query = filter.unwrap_or("").to_lowercase();
    agents
        .iter()
        .filter(|agent| matches(agent, &query))
        .collect()
}

fn matches(agent: &Agent, query: &str) -> bool {
    let haystacks = [Some(agent.label.as_str()), agent.title.as_deref()];
    haystacks
        .into_iter()
        .flatten()
        .any(|text| text.to_lowercase().contains(query))
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
        let Some(event) = events.next() else {
            return Ok(());
        };
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
}
