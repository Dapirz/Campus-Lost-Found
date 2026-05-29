<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FcmService
{
    protected $messaging;

    public function __construct()
    {
        $credentialsPath = env('FIREBASE_CREDENTIALS_PATH');
        
        if ($credentialsPath && file_exists($credentialsPath)) {
            $factory = (new Factory)->withServiceAccount($credentialsPath);
            $this->messaging = $factory->createMessaging();
        }
    }

    /**
     * Send push notification to a specific FCM Token.
     */
    public function sendToToken(string $token, string $title, string $body, array $data = []): bool
    {
        if (!$this->messaging) {
            return false;
        }

        try {
            $message = CloudMessage::new()
                ->withToken($token)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->send($message);
            
            return true;
        } catch (Throwable $e) {
            report($e);
            return false;
        }
    }
}
