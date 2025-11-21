/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   solve_game.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: eamor-di <eamor-di@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/19 17:32:42 by adride-l          #+#    #+#             */
/*   Updated: 2025/07/20 21:48:53 by eamor-di         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_rush01.h"

/*	Programa donde se resuelve el rush-01.
	En esta función rellena toda matriz (el tablero) y luego
	comprueba si esta bien. Si no, vuelve hacia atrás y desace los cambios y
	vuelve a probar con otras soluciones. Tecnicamente hace una recursividad
	de tipo "backtracking"
*/
int	solve_game(int **matrix, int *views, int row, int col)
{
	int	num;

	if (row == 4)
		return (check_views(matrix, views));
	if (col == 4)
		return (solve_game(matrix, views, row + 1, 0));
	num = 1;
	while (num <= 4)
	{
		if (is_already_there(matrix, row, col, num))
		{
			matrix[row][col] = num;
			if (solve_game(matrix, views, row, col + 1))
				return (1);
			matrix[row][col] = 0;
		}
		num++;
	}
	return (0);
}
