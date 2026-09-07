use std::cell::RefCell;
use std::io;

use ratatui::Terminal;
use ratatui::backend::TestBackend;
use ratatui::crossterm::event::{Event, KeyCode, KeyEvent, KeyModifiers};
use tmux_agents::agents::Agent;
use tmux_agents::app::{App, run};
use tmux_agents::tmux::{PaneId, PaneInfo, Tmux};

#[derive(Default)]
pub struct FakeTmux {
    focused: RefCell<Vec<PaneId>>,
}

impl FakeTmux {
    pub fn focused(&self) -> Vec<PaneId> {
        self.focused.borrow().clone()
    }
}

impl Tmux for FakeTmux {
    fn list_panes(&self) -> io::Result<Vec<PaneInfo>> {
        Ok(Vec::new())
    }

    fn focus(&self, pane: &PaneId) -> io::Result<()> {
        self.focused.borrow_mut().push(pane.clone());
        Ok(())
    }
}

pub fn key(code: KeyCode) -> io::Result<Event> {
    Ok(Event::Key(KeyEvent::new(code, KeyModifiers::NONE)))
}

pub fn ctrl(c: char) -> io::Result<Event> {
    Ok(Event::Key(KeyEvent::new(KeyCode::Char(c), KeyModifiers::CONTROL)))
}

pub struct Picker {
    pub terminal: Terminal<TestBackend>,
    pub app: App,
    pub tmux: FakeTmux,
}

impl Picker {
    pub fn new(agents: Vec<Agent>) -> Self {
        Self {
            terminal: Terminal::new(TestBackend::new(60, 8)).unwrap(),
            app: App::new(agents),
            tmux: FakeTmux::default(),
        }
    }

    pub fn run(&mut self, keys: Vec<io::Result<Event>>) -> io::Result<()> {
        run(&mut self.terminal, &mut self.app, keys.into_iter(), &self.tmux)
    }

    pub fn screen(&self) -> String {
        let buffer = self.terminal.backend().buffer();
        let width = buffer.area.width as usize;
        buffer
            .content
            .chunks(width)
            .map(|row| row.iter().map(|c| c.symbol()).collect::<String>())
            .collect::<Vec<_>>()
            .join("\n")
    }
}

pub fn agent(label: &str, pane: &str) -> Agent {
    Agent {
        pid: 1,
        label: label.to_string(),
        cwd: format!("/home/me/{label}").into(),
        pane: PaneId(pane.to_string()),
        session: "main".to_string(),
        window_index: 1,
        title: None,
    }
}
