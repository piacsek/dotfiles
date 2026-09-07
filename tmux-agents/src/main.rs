use std::env;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Duration;

use ratatui::crossterm::event::{self, Event};
use tmux_agents::agents::discover;
use tmux_agents::app::{App, Input, run};
use tmux_agents::cli::{self, Command};
use tmux_agents::process::is_alive;
use tmux_agents::registry::{load, sessions_dir};
use tmux_agents::tmux::{CliTmux, PaneInfo, Tmux};

const TICK: Duration = Duration::from_millis(500);

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
    let home = env::var_os("HOME").map(PathBuf::from).unwrap_or_default();
    let config_dir = env::var_os("CLAUDE_CONFIG_DIR").map(PathBuf::from);
    let sessions = sessions_dir(config_dir, &home);
    let mut source = || -> std::io::Result<Vec<_>> {
        let panes: Vec<PaneInfo> = tmux.list_panes()?;
        Ok(discover(load(&sessions), &panes, &is_alive))
    };
    let mut app = App::new(source()?);
    ratatui::run(|terminal| {
        run(
            terminal,
            &mut app,
            std::iter::from_fn(|| Some(next_input())),
            &tmux,
            &mut source,
        )
    })
}

fn next_input() -> std::io::Result<Input> {
    if !event::poll(TICK)? {
        return Ok(Input::Tick);
    }
    match event::read()? {
        Event::Key(key) => Ok(Input::Key(key)),
        _ => Ok(Input::Tick),
    }
}
