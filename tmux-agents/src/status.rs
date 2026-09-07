use crate::agents::Agent;
use crate::state::State;

pub fn render(agents: &[Agent]) -> String {
    let count = agents
        .iter()
        .filter(|a| State::from(a.status) == State::Working)
        .count();
    format!("#[fg=yellow]●{count}#[default]")
}
