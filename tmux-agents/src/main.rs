use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use ratatui::crossterm::event;
use tmux_agents::agents::discover;
use tmux_agents::app::{App, run};
use tmux_agents::cli::{self, Command};
use tmux_agents::process::is_alive;
use tmux_agents::registry::{load, sessions_dir};
use tmux_agents::tmux::{CliTmux, Tmux};

fn main() -> ExitCode {
    match cli::parse(env::args().skip(1)) {
        Ok(Command::Tui) => match tui() {
            Ok(()) => ExitCode::SUCCESS,
            Err(err) => fail(&err.to_string()),
        },
        Err(err) => fail(&err),
    }
}

fn fail(message: &str) -> ExitCode {
    eprintln!("tmux-agents: {message}");
    ExitCode::FAILURE
}

fn tui() -> std::io::Result<()> {
    let tmux = CliTmux::default();
    let panes = tmux.list_panes()?;
    let home = env::var_os("HOME").map(PathBuf::from).unwrap_or_default();
    let config_dir = env::var_os("CLAUDE_CONFIG_DIR").map(PathBuf::from);
    let records = load(&sessions_dir(config_dir, &home));
    let mut app = App::new(discover(records, &panes, &is_alive));
    ratatui::run(|terminal| {
        run(
            terminal,
            &mut app,
            std::iter::from_fn(|| Some(event::read())),
            &tmux,
        )
    })
}
