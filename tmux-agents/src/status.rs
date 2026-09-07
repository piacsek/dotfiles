use crate::agents::Agent;
use crate::state::State;

const ORDER: [State; 4] = [State::Blocked, State::Working, State::Idle, State::Unknown];

pub fn render(agents: &[Agent]) -> String {
    ORDER
        .into_iter()
        .filter_map(|state| {
            let count = agents
                .iter()
                .filter(|agent| State::from(agent.status) == state)
                .count();
            (count > 0).then(|| segment(state, count))
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn segment(state: State, count: usize) -> String {
    format!(
        "#[{}]{}{count}#[default]",
        state.tmux_style(),
        state.glyph()
    )
}
