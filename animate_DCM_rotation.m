function animate_rotation_matrix_additive_drift()
    tspan = linspace(0, 10, 20);
    dt = tspan(2) - tspan(1);

    % Initial rotation matrix
    R = eye(3);
    R_history = zeros(3, 3, length(tspan));
    R_history(:, :, 1) = R;

    omega_history = zeros(3, length(tspan));
    omega_norm = zeros(1, length(tspan));
    omega_x = zeros(1, length(tspan));  % To store omega_x over time
    omega_y = zeros(1, length(tspan));  % To store omega_y over time
    omega_z = zeros(1, length(tspan));  % To store omega_z over time
    det_R = zeros(1, length(tspan));
    det_R(1) = det(R);

    for i = 2:length(tspan)
        t = tspan(i-1);
        omega = angular_velocity_with_singularity(t);
        omega_hat = skew(omega);

        % ❌ Incorrect additive update
        R = R + dt * R * omega_hat;

        % Multiplicative update
        % R = R * expm(omega_hat * dt);

        % Store results
        R_history(:, :, i) = R;
        omega_history(:, i) = omega;
        omega_norm(i) = norm(omega);
        omega_x(i) = omega(1);
        omega_y(i) = omega(2);
        omega_z(i) = omega(3);
        det_R(i) = det(R);  % show numerical drift
    end

    % Plot setup
    figure('Position', [100 100 1000 700]);
    tlay = tiledlayout(3, 2, 'TileSpacing', 'compact');

    % --- 1. Cube animation
    ax1 = nexttile(tlay, [3 1]);
    axis equal; axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);
    view(3); grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Rotating Cube');
    hold on;

    [X, Y, Z] = ndgrid([-0.5 0.5]);
    cube_vertices = [X(:), Y(:), Z(:)]';
    cube_faces = [1 3 7 5; 2 4 8 6; 1 2 6 5;
                  3 4 8 7; 1 2 4 3; 5 6 8 7];
    face_colors = lines(6);
    cube_handle = patch('Faces', cube_faces, ...
                        'Vertices', cube_vertices', ...
                        'FaceColor', 'flat', ...
                        'FaceVertexCData', face_colors, ...
                        'EdgeColor', 'k');

    % --- 2. Angular velocity components plot
    ax2 = nexttile(tlay, 2);
    hold on;
    h_omega_x = plot(tspan(1), omega_x(1), 'r', 'DisplayName', '\omega_x');
    h_omega_y = plot(tspan(1), omega_y(1), 'g', 'DisplayName', '\omega_y');
    h_omega_z = plot(tspan(1), omega_z(1), 'b', 'DisplayName', '\omega_z');
    xlabel('Time (s)');
    ylabel('Angular Velocity Components');
    title('Angular Velocity Components (ω_x, ω_y, ω_z)');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;
    legend;

    % --- 3. Angular velocity magnitude plot
    ax3 = nexttile(tlay, 4);
    h_omega = plot(tspan(1), omega_norm(1), 'm', 'DisplayName', '|ω|');
    xlabel('Time (s)');
    ylabel('|ω|');
    title('Angular Velocity Magnitude');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;

    % --- 4. Determinant of R plot
    ax4 = nexttile(tlay, 6);
    h_detR = plot(tspan(1), det_R(1), 'k', 'DisplayName', 'det(R)');
    xlabel('Time (s)');
    ylabel('det(R)');
    title('Determinant of Rotation Matrix (Drift)');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;

    %% Animation loop
    for i = 1:length(tspan)
        R = R_history(:, :, i);
        rotated_vertices = R * cube_vertices;
        set(cube_handle, 'Vertices', rotated_vertices');

        % Update plots
        set(h_omega_x, 'XData', tspan(1:i), 'YData', omega_x(1:i));
        set(h_omega_y, 'XData', tspan(1:i), 'YData', omega_y(1:i));
        set(h_omega_z, 'XData', tspan(1:i), 'YData', omega_z(1:i));
        set(h_omega, 'XData', tspan(1:i), 'YData', omega_norm(1:i));
        set(h_detR,  'XData', tspan(1:i), 'YData', det_R(1:i));

        drawnow;
        pause(dt);  % slows animation to real-time-ish
    end
end

function omega = angular_velocity_with_singularity(t)
    wx = 0.01;
    wy = 0.5;
    wz = 0.01;
    omega = [wx; wy; wz];
end

function omega_hat = skew(omega)
    omega_hat = [    0, -omega(3),  omega(2);
                 omega(3),     0, -omega(1);
                -omega(2), omega(1),     0];
end
