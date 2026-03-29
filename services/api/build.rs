fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_server(true)
        .build_client(false)
        .compile_protos(
            &[
                "../../contracts/com/softmemes/myfeed/v1/common.proto",
                "../../contracts/com/softmemes/myfeed/v1/sources.proto",
                "../../contracts/com/softmemes/myfeed/v1/subscriptions.proto",
                "../../contracts/com/softmemes/myfeed/v1/feed.proto",
            ],
            &["../../contracts"],
        )?;
    Ok(())
}
