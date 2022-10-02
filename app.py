import streamlit as st
from utils.login import login
from utils.faq import faq
from utils.main import main_menu

st.set_page_config(layout="wide",
                   page_icon='style/favicon.jpg',
                   page_title='TalentWise')


with open('style/skin.css') as css:
    st.markdown(f"<style> {css.read()}</style>", unsafe_allow_html=True)



def app():
    pass


if __name__ == '__main__':

    block_logo = st.empty()
    block_phrase = st.empty()
    block_butt = st.empty()

    with block_logo:
        logo_column_1, logo_column_2, logo_column_3 = block_logo.columns(3)
        logo_column_2.image('style/logo.png')

    with block_phrase:
        col1,col2,col3 = st.columns(3)
        col2.text("""
        When you get a core group of ten great people then it 
        becomes self-policing as to who they let into that 
        group. So, I consider the most important job of some-
        one like myself is recruiting. - Steve Jobs. """)

    with block_butt:
        butt_column_1, butt_column_2, butt_column_3, butt_column_4, butt_column_5 = block_butt.columns([1,1,0.5,1,1])
        start_button = butt_column_3.button("Let's start!")

        if start_button:
            st.session_state['page'] = 'login'
            st.session_state.load_state = True
            app()

    if 'page' not in st.session_state:
        app()

    elif 'login' in st.session_state['page']:
        login(block_butt, block_logo, block_phrase)

    elif 'home' in st.session_state['page']:
        pass

    elif 'faq' in st.session_state['page']:
        faq(block_butt)

    elif 'main_menu' in st.session_state['page']:
        block_logo.empty()
        block_phrase.empty()
        main_menu(block_butt, block_logo)
