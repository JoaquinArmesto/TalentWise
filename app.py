import streamlit as st
from login import login
from faq import faq


def app():
    pass


if __name__ == '__main__':
    block_title = st.empty()
    block_app = st.empty()

    with block_title:
        block_title.markdown("<h1 style='text-align: center; color: black;'>TalentWise</h1><br>", unsafe_allow_html=True)

    with block_app:
        column_1, column_2, column_3 = block_app.columns(3)
        login_button = column_2.button('Login')

        if login_button:
            st.session_state['page'] = 'login'
            st.session_state.load_state = True
            app()

    if 'page' not in st.session_state:
        app()

    elif 'login' in st.session_state['page']:
        login(block_app)

    elif 'home' in st.session_state['page']:
        pass

    elif 'faq' in st.session_state['page']:
        faq(block_app)

