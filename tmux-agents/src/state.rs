use ratatui::style::Color;

use crate::registry::Status;

pub const WORD_WIDTH: usize = 7;

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum State {
    Blocked,
    Working,
    Idle,
    Unknown,
}

impl From<Status> for State {
    fn from(status: Status) -> Self {
        match status {
            Status::Busy | Status::Shell => State::Working,
            Status::Waiting => State::Blocked,
            Status::Idle => State::Idle,
            Status::Unknown => State::Unknown,
        }
    }
}

impl State {
    pub fn word(self) -> &'static str {
        match self {
            State::Working => "working",
            State::Blocked => "blocked",
            State::Idle => "idle",
            State::Unknown => "?",
        }
    }

    pub fn glyph(self) -> &'static str {
        match self {
            State::Working | State::Blocked => "●",
            State::Idle | State::Unknown => "○",
        }
    }

    pub fn color(self) -> Color {
        match self {
            State::Working => Color::Yellow,
            State::Blocked => Color::Red,
            State::Idle => Color::Green,
            State::Unknown => Color::DarkGray,
        }
    }

    pub fn tmux_style(self) -> &'static str {
        match self {
            State::Working => "fg=yellow",
            State::Blocked => "fg=red,bold",
            State::Idle => "fg=green",
            State::Unknown => "fg=brightblack",
        }
    }
}
