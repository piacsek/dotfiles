use crate::registry::Status;

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
}
