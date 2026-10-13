package com.example.campus.common;

import java.security.*;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/** 每个账号使用独立盐值；内存中只保留 PBKDF2 派生值。 */
public final class Passwords {
    private Passwords() {}
    public static String hash(String password) {
        byte[] salt = new byte[16]; new SecureRandom().nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt) + ":" + derive(password, salt);
    }
    public static boolean matches(String password, String stored) {
        String[] parts = stored.split(":");
        return MessageDigest.isEqual(Base64.getDecoder().decode(parts[1]),
                Base64.getDecoder().decode(derive(password, Base64.getDecoder().decode(parts[0]))));
    }
    private static String derive(String password, byte[] salt) {
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 60000, 256);
        try {
            return Base64.getEncoder().encodeToString(
                    SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded());
        } catch (GeneralSecurityException e) { throw new IllegalStateException("密码算法不可用", e); }
        finally { spec.clearPassword(); }
    }
}
