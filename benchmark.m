function out = benchmark(y, yg, dt)
%criterios integrales
out.IAE = iae(y, yg, dt);
out.ITAE = itae(y, yg, dt);
out.ISE = ise(y, yg, dt);
out.ITSE = itse(y, yg, dt);

%criterios estadisticos 
out.MSE = mse(y, yg);
out.RMSE = rmse(y, yg);
out.MAE = mae(y, yg);
out.MAPE = mape(y, yg);
out.FIT = fit(y, yg);
out.R2 = r2(y, yg);
end 


%criterios integrales ----------------------

function out = iae(y, yg, dt)
out = trapz(dt, abs(y-yg));
end

function out = itae(y, yg, dt)
out = trapz(dt, dt.*abs(y-yg));
end

function out = ise(y, yg, dt)
out = trapz(dt, (y-yg).^2);
end

function out = itse(y, yg, dt)
out = trapz(dt, dt.*(y-yg).^2);
end

%criterios estadisticos --------------------

function out = mse(y, yg)
out = mean((y - yg).^2);
end


function out = rmse(y, yg)
out = sqrt(mse(y, yg));
end

function out = mae(y, yg)
out = mean(abs(y - yg));
end

function out = mape(y, yg)
out = mean( abs( (y - yg) ./ (y + eps) ) ) * 100;
end

function out = fit(y, yg)
out = 100 * (1 - norm(y - yg) / norm(y - mean(y)) );
end

function out = r2(y, yg)
out = 1 - sum((y - yg).^2) / sum((y - mean(y)).^2);
end

