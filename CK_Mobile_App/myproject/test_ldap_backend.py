from flask import Flask, request, jsonify
from ldap3 import Server, Connection, ALL

app = Flask(__name__)

@app.route('/api/ldap-auth', methods=['POST'])
def ldap_auth():
    print("Received POST to /api/ldap-auth")
    data = request.get_json()
    print("Request data:", data)
    username = data.get('username')
    password = data.get('password')
    ldap_host = 'pjwstk.edu.pl'
    ldap_port = 389
    use_ssl = False
    base_dn = 'dc=pjwstk,dc=edu,dc=pl'
    # Construct bind_dn for PJATK
    bind_dn = f'cn={username},ou=studenci,ou=PJWSTK@Gdansk, {base_dn}'

    try:
        server = Server(ldap_host, port=ldap_port, use_ssl=use_ssl, get_info=ALL)
        conn = Connection(server, user=bind_dn, password=password, auto_bind=True)

        # Search for all attributes of the user
        search_filter = f'(cn={username})'
        conn.search(
            search_base=f'ou=studenci,ou=PJWSTK@Gdansk, {base_dn}',
            search_filter=search_filter,
            attributes=['*']
        )
        if conn.entries:
            print("LDAP user attributes:")
            for entry in conn.entries:
                print(entry.entry_to_json())
        else:
            print("No LDAP entries found for user.")

        conn.unbind()
        return jsonify({'status': 'success', 'message': 'LDAP authentication successful!'
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 401

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')