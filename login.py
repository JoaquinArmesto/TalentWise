import streamlit as st
from talentwise_connection import db_statement
from faq import faq

def login(block):

    block.empty()

    block_var = st.empty()


    with block_var:
        # container_1 = st.container()
        # container_2 = st.container()
        block_1 = st.container()
        column_1, column_2, column_3 = block_1.columns(3)

        user_var = column_2.text_input('User')
        pass_var = column_2.text_input('Password', type='password')

        button = column_2.button('sign in')
        button_sing_up = column_2.button('sing up')

    if button:
        query = f"""
        USE talent_wise;
        select user_name, user_pass from app_user where user_name like '{user_var}' and user_pass like '{pass_var}';
        """
        result = db_statement('database_credentials.json', query)

        if len(result) == 0:
            st.warning('Wrong user and/or password')
        else:
            block_var.empty()
            st.session_state['page'] = 'faq'
            st.session_state.load_state = True
            faq(block)
