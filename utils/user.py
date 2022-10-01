from utils.sql_connection import db_statement

class User:
    def __init__(self, user_name, user_pass, user_mail=None, user_sess=None):
        self.user = user_name
        self.pasw = user_pass
        self.mail = user_mail
        self.sess = user_sess

    def login_check(self):
        query = f"""
                use talent_wise;
                call sp_LoginCheck('{self.user}', '{self.pasw}', @return);"""

        check = db_statement('utils/database_credentials.json', query)[0][0][0]

        if check > 0:
            self.sess = True
            return_object = {
                'user':self.user,
                'pass':self.pasw,
                'mail':self.mail,
                'sess':self.sess
            }
            return return_object

    def create_account(self):
        pass
    def logout(self):
        pass