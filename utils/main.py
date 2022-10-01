import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def main_menu(block_logo=None, block_button=None):
    if block_logo is not None:
        block_logo.empty()
    elif block_button is not None:
        block_button.empty()


    button = st.sidebar.image('style/logo.png')


    sidebar_col_1, sidebar_col_2= st.sidebar.columns([0.2, 0.4])

    account_button = sidebar_col_2.button('Account')
    project_button = sidebar_col_2.button('Projects')


    block_var = st.empty()

    with block_var:
        column_1, column_2, column_3 = block_var.columns([0.5, 2, 0.5])
        dashboard, account_tab = column_2.tabs(['Dashboard', 'Users'])


        dashboard.write('ASDASDASD')