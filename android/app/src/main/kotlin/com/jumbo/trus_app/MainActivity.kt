package com.jumbo.trus_app

import android.content.Intent
import android.net.Uri
import android.os.CancellationSignal
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.core.content.ContextCompat
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePasswordRequest
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15+ renders edge-to-edge by default. Calling the AndroidX
        // compatibility API also gives older supported Android versions the
        // same inset behavior, so Flutter lays out the UI consistently.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        openPrivacyPolicyIfRequested(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        openPrivacyPolicyIfRequested(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CREDENTIAL_CHANNEL,
        ).setMethodCallHandler { call, channelResult ->
            if (call.method != "savePassword") {
                channelResult.notImplemented()
                return@setMethodCallHandler
            }

            val username = call.argument<String>("username")?.trim()
            val password = call.argument<String>("password")
            if (username.isNullOrEmpty() || password.isNullOrEmpty()) {
                channelResult.error(
                    "INVALID_CREDENTIALS",
                    "E-mail a heslo musí být vyplněné.",
                    null,
                )
                return@setMethodCallHandler
            }

            val request = CreatePasswordRequest(
                id = username,
                password = password,
            )
            CredentialManager.create(this).createCredentialAsync(
                context = this,
                request = request,
                cancellationSignal = CancellationSignal(),
                executor = ContextCompat.getMainExecutor(this),
                callback = object : CredentialManagerCallback<
                    CreateCredentialResponse,
                    CreateCredentialException
                > {
                    override fun onResult(result: CreateCredentialResponse) {
                        channelResult.success(null)
                    }

                    override fun onError(e: CreateCredentialException) {
                        if (e is CreateCredentialCancellationException) {
                            channelResult.error("CANCELLED", e.message, null)
                        } else {
                            channelResult.error(
                                "SAVE_FAILED",
                                e.message ?: "Správce hesel odmítl přihlašovací údaje uložit.",
                                null,
                            )
                        }
                    }
                },
            )
        }
    }

    companion object {
        private const val CREDENTIAL_CHANNEL = "com.jumbo.trus_app/credentials"
        private const val HEALTH_CONNECT_RATIONALE_ACTION =
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE"
        private const val VIEW_PERMISSION_USAGE_ACTION =
            "android.intent.action.VIEW_PERMISSION_USAGE"
        private const val PRIVACY_POLICY_URL =
            "https://trus.up.railway.app/privacy-policy"
    }

    private fun openPrivacyPolicyIfRequested(intent: Intent?) {
        val action = intent?.action
        if (
            action != HEALTH_CONNECT_RATIONALE_ACTION &&
            action != VIEW_PERMISSION_USAGE_ACTION
        ) {
            return
        }

        runCatching {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_POLICY_URL)))
        }
    }
}
