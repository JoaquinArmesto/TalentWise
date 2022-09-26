import streamlit as st
import pandas as pd


def faq(block):
    block.empty()
    df = pd.read_csv('../../Python/trellix_sample')
    len = df.shape[0] / 100




    st.markdown("### Frequently Asked Questions")

    what = st.expander("What's TalentWise")



    with what:
        left_column, right_column = st.columns([.1, 1])
        #x = st.sidebar.slider('Prueba')
        #st.dataframe(df.loc[0:x * len, :])
        chosen = st.radio(
            'Sorting hat',
            ("Gryffindor", "Ravenclaw", "Hufflepuff", "Slytherin"))
        st.write(f"You are in {chosen} house!")
        block_1 = st.container()
        user_var = block_1.text_input('User',key='das')



