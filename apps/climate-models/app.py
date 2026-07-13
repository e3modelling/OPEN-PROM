from __future__ import annotations

import streamlit as st

from climate_runner import (
    ClimateRunError,
    Settings,
    cleanup_expired_jobs,
    read_temperature_data,
    run_assessment,
    validate_emissions_csv,
)


st.set_page_config(page_title="OPEN-PROM Climate Assessment", layout="wide")
settings = Settings.from_environment()
cleanup_expired_jobs(settings)

st.title("OPEN-PROM Climate Assessment")
st.caption("Run CICERO-SCM or MAGICC against an IAMC emissions pathway.")

with st.sidebar:
    st.header("Assessment settings")
    model_label = st.selectbox("Climate model", ["CICERO-SCM", "MAGICC 7.5.3"])
    model = "ciceroscm" if model_label == "CICERO-SCM" else "magicc"
    num_cfgs = st.number_input(
        "Probabilistic configurations", min_value=1, max_value=600, value=600
    )
    batch_size = st.number_input(
        "Scenario batch size", min_value=1, max_value=100, value=20
    )
    st.info(
        "Only one assessment can run at a time. Completed job files are retained "
        f"for {settings.retention_hours} hours."
    )

upload = st.file_uploader("Upload an IAMC emissions CSV", type=["csv"])
contents = upload.getvalue() if upload is not None else None

if contents:
    try:
        preview = validate_emissions_csv(contents, settings.max_upload_mb)
        st.success(
            f"Valid IAMC input: {len(preview.columns)} columns; "
            f"previewed {len(preview)} row(s)."
        )
        with st.expander("Input preview"):
            st.dataframe(preview, use_container_width=True)
    except ClimateRunError as exc:
        st.error(str(exc))
        contents = None

if st.button("Run climate assessment", type="primary", disabled=contents is None):
    try:
        with st.spinner("Running the climate assessment. This may take some time..."):
            result = run_assessment(
                settings,
                contents,
                model,
                int(num_cfgs),
                int(batch_size),
            )
        st.session_state["climate_result"] = result
    except ClimateRunError as exc:
        st.error(str(exc))

result = st.session_state.get("climate_result")
if result is not None and result.workbook.exists():
    st.success(
        f"Assessment completed in {result.elapsed_seconds / 60:.1f} minutes "
        f"(job {result.job_id[:8]})."
    )
    try:
        chart_data = read_temperature_data(result.workbook)
        st.subheader("Global warming above the 1850–1900 mean")
        st.line_chart(
            chart_data,
            x="Year",
            y="Temperature",
            color="Series",
        )
    except ClimateRunError as exc:
        st.warning(f"The workbook is available, but the chart could not be built: {exc}")

    first, second = st.columns(2)
    with first:
        st.download_button(
            "Download assessment workbook",
            data=result.workbook.read_bytes(),
            file_name=result.workbook.name,
            mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        )
    with second:
        st.download_button(
            "Download execution log",
            data=result.log.read_bytes(),
            file_name=f"climate-assessment-{result.job_id[:8]}.log",
            mime="text/plain",
        )

st.divider()
st.caption(
    "This service is designed for deployment behind a VPN or authenticated reverse proxy. "
    "Do not expose the Streamlit port directly to the public internet."
)
