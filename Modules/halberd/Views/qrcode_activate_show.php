<?= $this->extend(config('Auth')->views['layout']) ?>

<?= $this->section('title') ?><?= lang('QRAuth.qrcode2FATitle') ?> <?= $this->endSection() ?>

<?= $this->section('main') ?>

<div class="container d-flex justify-content-center p-5">
    <div class="card col-12 col-md-5 shadow-sm">
        <div class="card-body">
            <h5 class="card-title mb-5"><?= lang('QRAuth.qrcode2FATitle') ?></h5>

            <?php if (session('error')) : ?>
                <div class="alert alert-danger"><?= session('error') ?></div>
            <?php endif ?>

            <p><?= lang('QRAuth.qrcodeActivateBody') ?></p>

            <p><?= $qrcode ?></p>

            <form action="<?= site_url('auth/a/verify') ?>" method="post">
                <?= csrf_field() ?>

                <!-- Code -->
                <div class="mb-2">
                    <input type="text" class="form-control" name="token" placeholder="000000" inputmode="numeric"
                        pattern="[0-9]*" autocomplete="one-time-code" value="<?= old('token') ?>" required />
                </div>

                <div class="d-grid col-8 mx-auto m-3">
                    <button type="submit" class="btn btn-primary btn-block"><?= lang('Auth.confirm') ?></button>
                </div>

            </form>
        </div>
    </div>
</div>

<?= $this->endSection() ?>
