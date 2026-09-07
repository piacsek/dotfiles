use std::io;
use std::path::PathBuf;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PaneId(pub String);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PaneInfo {
    pub id: PaneId,
    pub session: String,
    pub window_id: String,
    pub window_index: u32,
    pub current_path: PathBuf,
    pub title: String,
}

pub trait Tmux {
    fn list_panes(&self) -> io::Result<Vec<PaneInfo>>;
    fn focus(&self, pane: &PaneId) -> io::Result<()>;
}

pub fn parse_pane_ref(s: &str) -> Option<PaneId> {
    let (_, pane) = s.rsplit_once('.')?;
    pane.starts_with('%').then(|| PaneId(pane.to_string()))
}

pub fn parse_list_panes(stdout: &str) -> Vec<PaneInfo> {
    stdout.lines().filter_map(parse_pane_line).collect()
}

fn parse_pane_line(line: &str) -> Option<PaneInfo> {
    let mut fields = line.splitn(6, '\t');
    let id = fields.next()?;
    let session = fields.next()?;
    let window_id = fields.next()?;
    let window_index = fields.next()?.parse().ok()?;
    let current_path = fields.next()?;
    let title = fields.next().unwrap_or_default();
    Some(PaneInfo {
        id: PaneId(id.to_string()),
        session: session.to_string(),
        window_id: window_id.to_string(),
        window_index,
        current_path: PathBuf::from(current_path),
        title: title.to_string(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_pane_ref_extracts_pane_id_or_rejects_garbage() {
        assert_eq!(
            parse_pane_ref("dotfiles:@7.%53"),
            Some(PaneId("%53".to_string()))
        );
        assert_eq!(parse_pane_ref("garbage"), None);
        assert_eq!(parse_pane_ref("a.b"), None);
        assert_eq!(parse_pane_ref(""), None);
    }

    #[test]
    fn parse_list_panes_reads_tab_separated_rows_with_title_last() {
        let stdout = "%53\tdotfiles\t@7\t2\t/Users/me/dotfiles\t✳ Fix the picker now\n\
                      %3\tws-common\t@2\t1\t/Users/me/ws\tFelipes-MacBook-Pro.local\n";

        let panes = parse_list_panes(stdout);

        assert_eq!(
            panes,
            vec![
                PaneInfo {
                    id: PaneId("%53".to_string()),
                    session: "dotfiles".to_string(),
                    window_id: "@7".to_string(),
                    window_index: 2,
                    current_path: PathBuf::from("/Users/me/dotfiles"),
                    title: "✳ Fix the picker now".to_string(),
                },
                PaneInfo {
                    id: PaneId("%3".to_string()),
                    session: "ws-common".to_string(),
                    window_id: "@2".to_string(),
                    window_index: 1,
                    current_path: PathBuf::from("/Users/me/ws"),
                    title: "Felipes-MacBook-Pro.local".to_string(),
                },
            ]
        );
    }
}
