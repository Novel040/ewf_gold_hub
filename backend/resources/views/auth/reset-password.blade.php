
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reset Password - EWF Gold Hub</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            background: #f5f3ee;
            font-family: Arial, sans-serif;
            color: #252525;
        }
        .card {
            width: 100%;
            max-width: 420px;
            padding: 28px;
            border-radius: 18px;
            background: white;
            box-shadow: 0 8px 30px rgba(0,0,0,.08);
        }
        h1 { margin: 0 0 10px; font-size: 25px; }
        p { color: #666; line-height: 1.5; }
        label {
            display: block;
            margin: 18px 0 8px;
            font-weight: 600;
        }
        input {
            width: 100%;
            padding: 13px;
            border: 1px solid #ccc;
            border-radius: 9px;
            font-size: 16px;
        }
        button {
            width: 100%;
            margin-top: 22px;
            padding: 14px;
            border: 0;
            border-radius: 9px;
            background: #b58a35;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }
        button:disabled { opacity: .6; }
        #message {
            margin-top: 16px;
            overflow-wrap: anywhere;
        }
    </style>
</head>
<body>
    <main class="card">
        <h1>Reset Password</h1>
        <p>Buat password baru untuk akun EWF Gold Hub kamu.</p>

        <form id="resetForm">
            <input type="hidden" id="email"
                   value="{{ $email }}">
            <input type="hidden" id="token"
                   value="{{ $token }}">

            <label for="password">Password baru</label>
            <input id="password" type="password"
                   minlength="8" autocomplete="new-password"
                   required placeholder="Minimal 8 karakter">

            <label for="confirmation">Konfirmasi password baru</label>
            <input id="confirmation" type="password"
                   minlength="8" autocomplete="new-password"
                   required placeholder="Masukkan ulang password">

            <button id="submitButton" type="submit">
                Simpan Password Baru
            </button>
            <p id="message" role="status" aria-live="polite"></p>
        </form>
    </main>

    <script>
        const form = document.getElementById('resetForm');
        const message = document.getElementById('message');
        const button = document.getElementById('submitButton');

        form.addEventListener('submit', async function (event) {
            event.preventDefault();

            const email = document.getElementById('email').value.trim();
            const token = document.getElementById('token').value;
            const password = document.getElementById('password').value;
            const password_confirmation =
                document.getElementById('confirmation').value;

            if (!email || !token) {
                message.textContent =
                    'Email atau token tidak tersedia. Minta tautan reset baru.';
                return;
            }

            if (password !== password_confirmation) {
                message.textContent = 'Konfirmasi password tidak cocok.';
                return;
            }

            button.disabled = true;
            message.textContent = 'Sedang menyimpan password...';

            try {
                const response = await fetch('/api/reset-password', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        email,
                        token,
                        password,
                        password_confirmation
                    })
                });

                const data = await response.json();

                if (!response.ok) {
                    const errors = data.errors
                        ? Object.values(data.errors).flat().join(' ')
                        : data.message;

                    message.textContent =
                        errors || 'Reset password gagal. Coba lagi.';
                    return;
                }

                message.textContent =
                    data.message ||
                    'Password berhasil diubah. Silakan login dengan password baru.';

                form.reset();
            } catch (error) {
                message.textContent =
                    'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.';
            } finally {
                button.disabled = false;
            }
        });
    </script>
</body>
</html>
