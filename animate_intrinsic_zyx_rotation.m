function animate_intrinsic_zyx_rotation()
    tspan = linspace(0, 20, 400);
    dt = tspan(2) - tspan(1);
    angles = zeros(3, length(tspan));
    detM = zeros(1, length(tspan));
    angle_dot_mag = zeros(1, length(tspan));  

    for i = 2:length(tspan)
        t = tspan(i-1);
        alpha = angles(1, i-1);
        beta  = angles(2, i-1);
        gamma = angles(3, i-1);

        omega = angular_velocity_with_singularity(t);

        M = [ 0, -sin(alpha),  cos(alpha)*cos(beta);
              0,  cos(alpha),  sin(alpha)*cos(beta);
              1,          0,             -sin(beta)];

        detM(i) = det(M);  % track determinant

        angle_dot = M \ omega;
        angle_dot_mag(i) = norm(angle_dot);  % track norm
        angles(:, i) = angles(:, i-1) + angle_dot * dt;
    end

    %% Set up figure with custom tiled layout
    figure('Position', [100 100 1000 600]);
    t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    % --- 1. Cube animation subplot (spans 3 rows)
    ax1 = nexttile(1, [3 1]);
    axis equal; axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);
    view(3); grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Rotating Cube (ZYX intrinsic)');
    hold on;

    [X, Y, Z] = ndgrid([-0.5 0.5]);
    cube_vertices = [X(:), Y(:), Z(:)]';
    cube_faces = [1 3 7 5; 2 4 8 6; 1 2 6 5; 3 4 8 7; 1 2 4 3; 5 6 8 7];
    face_colors = lines(6);
    cube_handle = patch('Faces', cube_faces, ...
                        'Vertices', cube_vertices', ...
                        'FaceColor', 'flat', ...
                        'FaceVertexCData', face_colors, ...
                        'EdgeColor', 'k');

    % --- 2. Angle plot
    ax2 = nexttile(2);
    hold on;
    h_alpha = plot(tspan(1), rad2deg(angles(1,1)), 'r', 'DisplayName', '\alpha (yaw)');
    h_beta  = plot(tspan(1), rad2deg(angles(2,1)), 'g', 'DisplayName', '\beta (pitch)');
    h_gamma = plot(tspan(1), rad2deg(angles(3,1)), 'b', 'DisplayName', '\gamma (roll)');
    legend();
    xlabel('Time (s)');
    ylabel('Angle (°)');
    title('Tait-Bryan Angles');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;

    % --- 3. Determinant plot
    ax3 = nexttile(4);
    h_det = plot(tspan(1), detM(1), 'k', 'DisplayName', 'det(M)');
    xlabel('Time (s)');
    ylabel('det(M)');
    title('Determinant of M');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;

    % --- 4. angle_dot magnitude plot
    ax4 = nexttile(6);
    h_dotmag = plot(tspan(1), 0, 'm', 'DisplayName', '|angle\_dot|');
    xlabel('Time (s)');
    ylabel('|angle\_dot|');
    title('Magnitude of angle\_dot');
    grid on;
    xlim([tspan(1) tspan(end)]);
    ylim padded;

    %% Animation loop
    for i = 1:length(tspan)
        alpha = angles(1, i);
        beta  = angles(2, i);
        gamma = angles(3, i);

        Rz = [cos(alpha), -sin(alpha), 0;
              sin(alpha),  cos(alpha), 0;
                      0,           0, 1];
        Ry = [cos(beta), 0, sin(beta);
                    0, 1,        0;
             -sin(beta), 0, cos(beta)];
        Rx = [1,         0,          0;
              0, cos(gamma), -sin(gamma);
              0, sin(gamma),  cos(gamma)];
        R = Rz * Ry * Rx;

        rotated_vertices = R * cube_vertices;
        set(cube_handle, 'Vertices', rotated_vertices');

        % Update plots
        set(h_alpha, 'XData', tspan(1:i), 'YData', rad2deg(angles(1,1:i)));
        set(h_beta,  'XData', tspan(1:i), 'YData', rad2deg(angles(2,1:i)));
        set(h_gamma, 'XData', tspan(1:i), 'YData', rad2deg(angles(3,1:i)));
        set(h_det,   'XData', tspan(1:i), 'YData', detM(1:i));
        set(h_dotmag, 'XData', tspan(1:i), 'YData', angle_dot_mag(1:i));

        drawnow;
        pause(0.05);
    end
end

function omega = angular_velocity_with_singularity(t)
    wx = 0.01;
    wy = 0.5;
    wz = 0.01;
    omega = [wx; wy; wz];
end

% function omega = angular_velocity_with_singularity(t)
%     wx = 0.5;
%     wy = 0.0;
%     wz = 0.0;
%     omega = [wx; wy; wz];
% end
