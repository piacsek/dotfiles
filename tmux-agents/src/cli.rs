#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn no_args_means_tui_and_anything_else_is_a_usage_error() {
        assert_eq!(parse(Vec::<String>::new()), Ok(Command::Tui));
        let err = parse(vec!["bogus".to_string()]).unwrap_err();
        assert!(err.contains("usage"), "{err}");
    }
}
