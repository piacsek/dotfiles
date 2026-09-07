mod support;

use support::agent_with_status;
use tmux_agents::registry::Status;
use tmux_agents::status::render;

#[test]
fn one_working_agent_renders_a_yellow_dot_with_its_count() {
    let agents = vec![agent_with_status("a", "%1", Status::Busy)];

    assert_eq!(render(&agents), "#[fg=yellow]●1#[default]");
}
