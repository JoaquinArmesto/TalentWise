import streamlit as st
from utils.sql_connection import db_statement
from utils.main import main_menu
from utils.user import User


def login(block, block_logo, block_phrase):
    block.empty()
    block_phrase.empty()
    block_var = st.empty()



    with block_var:
        column_1, column_2, column_3 = block_var.columns(3)
        login_tab, account_tab = column_2.tabs(['Sign in', 'Sign up'])

        user_var = login_tab.text_input('User', key='user')
        pass_var = login_tab.text_input('Password', type='password', key='password')
        login_button = login_tab.button('Login')

        new_user_var = account_tab.text_input('User', key='new_user')
        new_pass_var = account_tab.text_input('Password', type='password', key='new_password')
        new_mail_var = account_tab.text_input('Email', key='new_email')
        new_gend_var = account_tab.selectbox('Gender', ['Male', 'Female', 'Other', ], key='gender')
        new_role_var = account_tab.selectbox('Role', ['Recruiter', 'Sourcer', 'Manager'], key='role')
        new_phon_var = account_tab.text_input('Phone', key='phone')
        create_button = account_tab.button('Create account')

    # security_counter = 0


    if create_button:
        if len(new_user_var) < 6:
            account_tab.error('The user name should be six character long or more')
        elif len(new_pass_var) < 8:
            account_tab.error('The user password should be eight character long or more')
        else:
            query_test = f"""
                    use talent_wise;
                    select * from app_user where user_name = '{new_user_var.strip()}' or user_email = '{new_mail_var.strip()}'
                    """
            create_query = db_statement('utils/database_credentials.json', query_test)
            if len(create_query) == 0:

                query = f"""
                        use talent_wise;
                        call sp_CreateAccount('{new_user_var}', '{new_pass_var}', '{new_mail_var}', '{new_gend_var}', '{new_role_var}', '{new_phon_var}');
                        """
                create_result = db_statement('utils/database_credentials.json', query)
                st.session_state['page'] = ''
                st.experimental_rerun()

            else:
                account_tab.error('The user or email already exist')




    if login_button:
        if len(user_var) == 0:
            login_tab.error('You need to enter a valid user')
        elif len(pass_var) == 0:
            login_tab.error('You need to enter a valid password')
        else:
            user = User(user_var, pass_var).login_check()

            if user is not None:
                block_var.empty()
                block_logo.empty()
                st.session_state['page'] = 'main_menu'
                st.session_state['userx'] = user
                main_menu(block_var)
            else:
                login_tab.error('Wrong user and/or password')