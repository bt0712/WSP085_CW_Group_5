import streamlit as st
import pandas as pd
 
st.set_page_config(page_title="MMS Dashboard", layout="wide")
 
st.title("Chief Engineer MMS Dashboard")
st.caption("Read-only dashboard for configuration, model status and approval decisions")
 
st.header("1. Upload SysML HTML Report")
html_file = st.file_uploader("Upload MagicDraw HTML export", type=["html", "htm"])
 
if html_file:
    html_content = html_file.read().decode("utf-8", errors="ignore")
    st.components.v1.html(html_content, height=500, scrolling=True)
else:
    st.info("Upload a MagicDraw HTML report to display SysML evidence.")
 
st.header("2. Upload Model Status CSV")
csv_file = st.file_uploader("Upload model status CSV", type=["csv"])
 
if csv_file:
    df = pd.read_csv(csv_file)
    st.dataframe(df, use_container_width=True)
else:
    st.info("Upload a CSV showing model status, evidence status or parameter changes.")
 
st.header("3. Chief Engineer Decision")
 
decision = st.radio(
    "Decision:",
    ["Awaiting Review", "Approve Baseline", "Reject Change", "Request Re-Verification"]
)
 
if st.button("Record Decision"):
    st.success(f"Decision selected: {decision}")
    st.write("In the full MMS, this would be recorded against the GitHub baseline or pull request.")
