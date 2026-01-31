document.addEventListener('DOMContentLoaded', function() {
    const mailBtn = document.getElementById('mail-btn');
    const modal = document.getElementById('mail-modal');
    const cancelBtn = document.getElementById('mail-cancel');
    const confirmBtn = document.getElementById('mail-confirm');

    if (mailBtn && modal) {
        // メールボタン → モーダル表示
        mailBtn.addEventListener('click', function(e) {
            e.preventDefault();
            modal.classList.add('show');
        });

        // キャンセルボタン → モーダル閉じる
        cancelBtn.addEventListener('click', function() {
            modal.classList.remove('show');
        });

        // 確認ボタン → mailto: を開く
        confirmBtn.addEventListener('click', function() {
            const encoded = 'bWFpbEBzLWF0c3VraS5qcA==';
            const decoded = atob(encoded);

            const subject = '[Webページからのお問い合わせ] {問い合わせのタイトルを入力してください}';
            const body = `[お名前]
{お名前を入力してください}

[ご所属]
{ご所属先を入力してください}

[お問い合わせ内容]
{お問い合わせの内容を入力してください}`;

            const mailtoUrl = 'mailto:' + decoded
                + '?subject=' + encodeURIComponent(subject)
                + '&body=' + encodeURIComponent(body);

            window.location.href = mailtoUrl;
            modal.classList.remove('show');
        });

        // モーダル外クリック → 閉じる
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                modal.classList.remove('show');
            }
        });
    }
});
