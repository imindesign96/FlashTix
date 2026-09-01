package com.flashtix.api.auth;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

interface RefreshSessionRepository extends JpaRepository<RefreshSessionEntity, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select session from RefreshSessionEntity session join fetch session.user where session.tokenHash = :tokenHash")
    Optional<RefreshSessionEntity> findByTokenHashForUpdate(@Param("tokenHash") String tokenHash);
}
