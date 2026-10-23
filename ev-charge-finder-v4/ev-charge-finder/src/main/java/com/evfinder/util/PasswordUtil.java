package com.evfinder.util;

import org.mindrot.jbcrypt.BCrypt;

/** Passwords are never stored as plain text; only the BCrypt hash is stored. */
public class PasswordUtil {
    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt());
    }

    public static boolean check(String plain, String hash) {
        return BCrypt.checkpw(plain, hash);
    }
}
