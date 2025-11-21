/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: eamor-di <eamor-di@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/19 17:32:22 by adride-l          #+#    #+#             */
/*   Updated: 2025/07/20 21:48:45 by eamor-di         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */


#include "ft_rush01.h"
/*	Programa principal
	Donde el se gestiona todo los errores y creacion de la matriz y vector
	de vistas (parametro de entrada). En caso de que haya mas de dos
	argumentos sale error o en caso de que no tenga solución también sale
	error.
*/
int	main(int argc, char **argv)
{
	int	**matrix;
	int	*views;

	if (argc != 2)
	{
		write_string("Error\n", 6);
		return (-1);
	}
	views = views_array(argv[1]);
	if (!views)
		return (write_string("Error\n", 6), 1);
	matrix = malloc_matrix();
	if (!matrix || !solve_game(matrix, views, 0, 0))
	{
		write_string("Error\n", 6);
		free_matrix(matrix);
		free_array(views);
		return (-1);
	}
	print_matrix(matrix);
	free_matrix(matrix);
	free_array(views);
	return (0);
}
